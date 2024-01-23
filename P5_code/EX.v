`include "const.v"
module EX (
    input clk,
    input rst,
    input [31:0] EX_pc,
    input [31:0] EX_instr,
    input [31:0] EX_rs_base,
    input [31:0] EX_rt_use,
    input [31:0] EX_rt,
    output reg [31:0] EX_out,
    output reg [31:0] EX_rt_MEM,
    output reg [31:0] EX_instr_MEM,
    output reg [31:0] EX_pc_MEM
);
    reg [31:0] out;
    always@(posedge clk) begin
        if(rst==1) begin
            EX_out<=0;
            EX_instr_MEM<=0;
            EX_rt_MEM<=0;
            EX_pc_MEM<=0;
        end
        else begin
            EX_out<=out;
            EX_rt_MEM<=EX_rt;
            EX_instr_MEM<=EX_instr;
            EX_pc_MEM<=EX_pc;
        end
    end
    always@(*) begin
        case (EX_instr[`opcode])
            6'b0:out<=(EX_instr[`func]==`add)?EX_rs_base+EX_rt_use:
                        (EX_instr[`func]==`sub)?EX_rs_base-EX_rt_use:0;
            `ori:out<=EX_rs_base|{16'b0,EX_instr[`imm]};
            `lw:out<=EX_rs_base+{{16{EX_instr[15]}},EX_instr[`offset]};
            `sw:out<=EX_rs_base+{{16{EX_instr[15]}},EX_instr[`offset]};
            `lui:out<={EX_instr[`imm],16'b0};
            `jal:out<=EX_pc+8;
            default: ;
        endcase
    end
endmodule