`include "const.v"
module MEM (
    input clk,
    input rst,
    input [31:0] MEM_pc,
    input [31:0] MEM_instr,
    input [31:0] MEM_addr,//要读/写的地址
    input [31:0] MEM_data,//从DM读出的数据

    output MEM_new,
    output [4:0] MEM_new_addr,

    output reg [31:0] MEM_data_WB,//传向下一级的数据
    output reg [31:0] EX_data_WB,
    output reg [31:0] MEM_instr_WB,
    output reg [31:0] MEM_pc_WB

);
    wire [2:0] op;
    wire [31:0] data_out;

    assign op=(MEM_instr[`opcode]==`lw)?3'b000:
                (MEM_instr[`opcode]==`lh)?3'b100:3'b010;
    assign MEM_new=(MEM_instr[`opcode]==0&&(MEM_instr[`func]==`add||
                                            MEM_instr[`func]==`sub||
                                            MEM_instr[`func]==`and||
                                            MEM_instr[`func]==`or||
                                            MEM_instr[`func]==`slt||
                                            MEM_instr[`func]==`sltu||
                                            MEM_instr[`func]==`mfhi||
                                            MEM_instr[`func]==`mflo))||
                    MEM_instr[`opcode]==`ori||
                    MEM_instr[`opcode]==`lui||
                    MEM_instr[`opcode]==`andi||
                    MEM_instr[`opcode]==`addi||
                    MEM_instr[`opcode]==`jal||
                    (MEM_instr[`opcode]==6'b010000&&MEM_instr[25:21]==`mfc0);
    assign MEM_new_addr=(MEM_instr[`opcode]==0&&(MEM_instr[`func]==`add||
                                            MEM_instr[`func]==`sub||
                                            MEM_instr[`func]==`and||
                                            MEM_instr[`func]==`or||
                                            MEM_instr[`func]==`slt||
                                            MEM_instr[`func]==`sltu||
                                            MEM_instr[`func]==`mfhi||
                                            MEM_instr[`func]==`mflo))?MEM_instr[`rd]:
                        ( MEM_instr[`opcode]==`ori||
                        MEM_instr[`opcode]==`lui||
                        MEM_instr[`opcode]==`andi||
                        MEM_instr[`opcode]==`addi||
                        (MEM_instr[`opcode]==6'b010000&&MEM_instr[25:21]==`mfc0))?MEM_instr[`rt]:31;

    ext extend(
        .A(MEM_addr[1:0]),
        .Din(MEM_data),
        .Op(op),
        .Dout(data_out)
    );

    // always@(*) begin
    //     case(MEM_instr[`opcode])
    //         `sw:out_addr[`opcode]=`sw;
    //         `sh:out_addr[`opcode]=`sh;
    //         `sb:out_addr[`opcode]=`sb;
    //         default:begin
    //             m_data_byteen=4'b0000;
    //             case(MEM_instr[`opcode])
    //                 `lw:op=3'b000;
    //                 `lh:op=3'b100;
    //                 default:op=3'b010;
    //             endcase
    //         end
    //     endcase
    // end

    // always@(*) begin
    //     case(MEM_instr[`opcode])
    //         `sw:m_data_byteen=4'b1111;
    //         `sh:m_data_byteen=(MEM_addr[1])?4'b1100:4'b0011;
    //         `sb:m_data_byteen=(MEM_addr[1:0]==2'b00)?4'b0001:
    //                             (MEM_addr[1:0]==2'b01)?4'b0010:
    //                             (MEM_addr[1:0]==2'b10)?4'b0100:4'b1000;
    //         default:begin
    //             m_data_byteen=4'b0000;
    //             case(MEM_instr[`opcode])
    //                 `lw:op=3'b000;
    //                 `lh:op=3'b100;
    //                 default:op=3'b010;
    //             endcase
    //         end
    //     endcase
    // end

    always@(posedge clk) begin
        if(rst==1) begin
            MEM_data_WB<=0;
            EX_data_WB<=0;
            MEM_instr_WB<=0;
            MEM_pc_WB<=0;
        end
        else begin
            MEM_data_WB<=data_out;
            EX_data_WB<=MEM_addr;
            MEM_instr_WB<=MEM_instr;
            MEM_pc_WB<=MEM_pc;
        end
    end
endmodule