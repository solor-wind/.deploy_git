`include "const.v"
module WB (
    input clk,
    input rst,
    input [31:0] WB_pc,
    input [31:0] WB_instr,
    input [31:0] WB_lw_data,
    input [31:0] WB_alu_data,
    output WB_we_ID,
    output [4:0] WB_addr_ID,
    output [31:0] WB_data_ID,
    output [31:0] WB_pc_ID
);
    wire calr_rd;//写rd寄存器
    wire cali_rt;//写rt寄存器
    wire lw_rt;
    assign calr_rd=WB_instr[`opcode]==0&&
                (WB_instr[`func]==`add||
                WB_instr[`func]==`sub||
                WB_instr[`func]==`and||
                WB_instr[`func]==`or||
                WB_instr[`func]==`slt||
                WB_instr[`func]==`sltu||
                WB_instr[`func]==`mfhi||
                WB_instr[`func]==`mflo);
    assign cali_rt=WB_instr[`opcode]==`ori||
                    WB_instr[`opcode]==`lui||
                    WB_instr[`opcode]==`andi||
                    WB_instr[`opcode]==`addi;
    assign lw_rt=WB_instr[`opcode]==`lw||
                WB_instr[`opcode]==`lh||
                WB_instr[`opcode]==`lb;

    assign WB_we_ID=calr_rd||cali_rt||lw_rt||
                    WB_instr[`opcode]==`jal||
                    (WB_instr[`opcode]==6'b010000&&WB_instr[25:21]==`mfc0);
    assign WB_addr_ID=calr_rd?WB_instr[`rd]:
                       (cali_rt||lw_rt||(WB_instr[`opcode]==6'b010000&&WB_instr[25:21]==`mfc0))?WB_instr[`rt]:31;
    assign WB_data_ID=(cali_rt||calr_rd||WB_instr[`opcode]==`jal||(WB_instr[`opcode]==6'b010000&&WB_instr[25:21]==`mfc0))?WB_alu_data:WB_lw_data;
    assign WB_pc_ID=WB_pc;
endmodule