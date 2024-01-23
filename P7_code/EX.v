`include "const.v"
module EX (
    input clk,
    input rst,
    input req,
    input [31:0] EX_pc,
    input [31:0] EX_instr,
    input [31:0] EX_rs_base,
    input [31:0] EX_rt,
    input [31:0] EX_CP0,
    input [31:0] EX_exc,
    output [31:0] EX_exc_CP0,
    output reg [31:0] EX_out,
    output reg [31:0] EX_rt_MEM,
    output reg [31:0] EX_instr_MEM,
    output reg [31:0] EX_pc_MEM,
    
    output busy
);
    reg [32:0] out;
    wire [2:0] start;
    wire [31:0] hi;
    wire [31:0] lo;

    assign start=(EX_instr[`opcode]!=0||req)?0:
                (EX_instr[`func]==`mult)?1:
                (EX_instr[`func]==`multu)?2:
                (EX_instr[`func]==`div)?3:
                (EX_instr[`func]==`divu)?4:
                (EX_instr[`func]==`mthi)?5:
                (EX_instr[`func]==`mtlo)?6:0;
    mul muldiv(
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(EX_rs_base),
        .B(EX_rt),
        .busy(busy),
        .hi(hi),
        .lo(lo)
    );
    always@(posedge clk) begin
        if(rst==1) begin
            EX_out<=0;
            EX_instr_MEM<=0;
            EX_rt_MEM<=0;
            EX_pc_MEM<=0;
        end
        else if(req==1) begin
            EX_out<=0;
            EX_instr_MEM<=0;
            EX_rt_MEM<=0;
            EX_pc_MEM<=0;
        end
        else begin
            EX_out<=out[31:0];//
            EX_rt_MEM<=EX_rt;
            EX_instr_MEM<=EX_instr;
            EX_pc_MEM<=EX_pc;
        end
    end

    always@(*) begin
        out=0;
        case (EX_instr[`opcode])
            6'b0:begin
                case (EX_instr[`func])
                    `add:out={EX_rs_base[31],EX_rs_base}+{EX_rt[31],EX_rt};
                    `sub:out={EX_rs_base[31],EX_rs_base}-{EX_rt[31],EX_rt};
                    `and:out=EX_rs_base&EX_rt;
                    `or:out=EX_rs_base|EX_rt;
                    `slt:out=($signed(EX_rs_base)<$signed(EX_rt))?1:0;
                    `sltu:out=(EX_rs_base<EX_rt)?1:0;
                    `mfhi:out=hi;
                    `mflo:out=lo;
                    default:;
                endcase
            end
            `ori:out=EX_rs_base|{16'b0,EX_instr[`imm]};
            `andi:out=EX_rs_base&{16'b0,EX_instr[`imm]};
            `addi:out={EX_rs_base[31],EX_rs_base}+{{17{EX_instr[15]}},EX_instr[`imm]};
            `lui:out={EX_instr[`imm],16'b0};
            
            `jal:out=EX_pc+8;

            6'b010000:begin
                if(EX_instr[25:21]==`mfc0)
                    out=EX_CP0;
            end

            default:out={EX_rs_base[31],EX_rs_base}+{{17{EX_instr[15]}},EX_instr[`offset]};//lw,sw
        endcase
    end

    assign EX_exc_CP0=(EX_exc)?EX_exc:
                ((EX_instr[`opcode]==`lw&&out[1:0]!=0)||
                (EX_instr[`opcode]==`lh&&out[0]!=0)||
                ((EX_instr[`opcode]==`lh||EX_instr[`opcode]==`lb)&&((out[31:0]>=32'h7f00&&out[31:0]<=32'h7f0b)||(out[31:0]>=32'h7f10&&out[31:0]<=32'h7f1b)))||
                ((EX_instr[`opcode]==`lw||EX_instr[`opcode]==`lh||EX_instr[`opcode]==`lb)&&out[32]!=out[31])||
                ((EX_instr[`opcode]==`lw||EX_instr[`opcode]==`lh||EX_instr[`opcode]==`lb)&&((out[31:0]>=32'h3000&&out[31:0]<32'h7f00)||(out[31:0]>32'h7f23)||(out[31:0]>32'h7f0b&&out[31:0]<32'h7f10)||(out[31:0]>32'h7f1b&&out[31:0]<32'h7f20))))?4:

                ((EX_instr[`opcode]==`sw&&out[1:0]!=0)||
                (EX_instr[`opcode]==`sh&&out[0]!=0)||
                ((EX_instr[`opcode]==`sh||EX_instr[`opcode]==`sb)&&((out[31:0]>=32'h7f00&&out[31:0]<=32'h7f0b)||(out[31:0]>=32'h7f10&&out[31:0]<=32'h7f1b)))||
                ((EX_instr[`opcode]==`sw||EX_instr[`opcode]==`sh||EX_instr[`opcode]==`sb)&&out[32]!=out[31])||
                ((EX_instr[`opcode]==`sw||EX_instr[`opcode]==`sh||EX_instr[`opcode]==`sb)&&((out>=32'h7f08&&out<=32'h7f0b)||(out>=32'h7f18&&out<=32'h7f1b)))||
                ((EX_instr[`opcode]==`sw||EX_instr[`opcode]==`sh||EX_instr[`opcode]==`sb)&&((out[31:0]>=32'h3000&&out[31:0]<32'h7f00)||(out[31:0]>32'h7f23)||(out[31:0]>32'h7f0b&&out[31:0]<32'h7f10)||(out[31:0]>32'h7f1b&&out[31:0]<32'h7f20))))?5:

                ((EX_instr[`opcode]==0&&(EX_instr[`func]==`add||EX_instr[`func]==`sub))||EX_instr[`opcode]==`addi)&&out[32]!=out[31]?12:0;
endmodule