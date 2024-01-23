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
    assign WB_we_ID=((WB_instr[`opcode]==0&&(WB_instr[`func]==`add||WB_instr[`func]==`sub))||
                    WB_instr[`opcode]==`ori||
                    WB_instr[`opcode]==`lw||
                    WB_instr[`opcode]==`lui||
                    WB_instr[`opcode]==`jal);
    assign WB_addr_ID=(WB_instr[`opcode]==0&&(WB_instr[`func]==`add||WB_instr[`func]==`sub))?WB_instr[`rd]:
                        (WB_instr[`opcode]==`jal)?31:WB_instr[`rt];
    assign WB_data_ID=(WB_instr[`opcode]==`lw)?WB_lw_data:WB_alu_data;
    assign WB_pc_ID=WB_pc;
endmodule