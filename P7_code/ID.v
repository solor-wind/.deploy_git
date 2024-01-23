`include "const.v"
module ID(
    input clk,
    input rst,
    input stall,
    input req,
    input [31:0] EPC,

    input [31:0] ID_pc,
    input [31:0] ID_instr,
    
    input [31:0] WB_pc_ID,
    input ID_we,
    input [4:0] ID_addr,
    input [31:0] ID_data,

    input [2:0] ID_rs_sign,
    input [2:0] ID_rt_sign,
    input [31:0] ID_rs_data,
    input [31:0] ID_rt_data,

    input [31:0] ID_exc,
    input ID_BD,
    output reg [31:0] ID_exc_EX,
    output reg ID_BD_CP0,

    output reg [31:0] ID_rs_base,
    output reg [31:0] ID_rt,
    output [2:0] ID_j_IF,//即时跳转
    output [31:0] ID_pc_IF,
    output reg [31:0] ID_instr_EX,
    output reg [31:0] ID_pc_EX
);
    wire [31:0] ID_rs_use;//搭配转发使用
    wire [31:0] ID_rt_use;//搭配转发使用
    reg [31:0] grf [0:31];//32个寄存器
    integer i;

    assign ID_rs_use=ID_rs_sign?ID_rs_data://来自M级的转发
                    (ID_we==1&&ID_addr==ID_instr[`rs]&&ID_addr!=5'd0)?ID_data:grf[ID_instr[`rs]];//W级的转发（内部转发）
    assign ID_rt_use=ID_rt_sign?ID_rt_data:
                    (ID_we==1&&ID_addr==ID_instr[`rt]&&ID_addr!=5'd0)?ID_data:grf[ID_instr[`rt]];

    assign ID_j_IF=(stall==1||rst==1)?0://即时给出跳转信号而非存到流水线寄存器后再给出
                    (ID_instr[`opcode]==`beq&&ID_rs_use==ID_rt_use)?1:
                    (ID_instr[`opcode]==`jal)?2:
                    (ID_instr[`opcode]==0&&ID_instr[`func]==`jr)?3:
                    (ID_instr[`opcode]==`bne&&ID_rs_use!=ID_rt_use)?4:
                    (ID_instr[`opcode]==6'b010000&&ID_instr[`func]==`eret)?5:0;
    assign ID_pc_IF=(ID_j_IF==1)?ID_pc+4+{{14{ID_instr[15]}},ID_instr[`offset],2'b0}:
                    (ID_j_IF==2)?{ID_pc[31:28],ID_instr[`index],2'b0}:
                    (ID_j_IF==3)?ID_rs_use:
                    (ID_j_IF==4)?ID_pc+4+{{14{ID_instr[15]}},ID_instr[`offset],2'b0}:
                    (ID_j_IF==5)?EPC:ID_pc+4;

    always@(posedge clk) begin
        if(rst==1) begin
            for(i=0;i<32;i=i+1) begin
                grf[i]<=32'b0;
            end
            ID_rs_base<=0;
            ID_rt<=0;
            ID_instr_EX<=0;
            ID_pc_EX<=0;
            ID_exc_EX<=0;
            ID_BD_CP0<=0;
        end
        else if(req==1) begin
            if(ID_we==1) begin
                if(ID_addr!=0)
                grf[ID_addr]<=ID_data;
            end
            ID_rs_base<=0;
            ID_rt<=0;
            ID_instr_EX<=0;
            //ID_pc_EX<=0;
            ID_exc_EX<=0;
        end
        else if(stall==1) begin
            if(ID_we==1) begin
                if(ID_addr!=0)
                grf[ID_addr]<=ID_data;
            end
            ID_instr_EX<=0;
            //ID_pc_EX<=0;
            ID_exc_EX<=0;

            ID_pc_EX<=ID_pc;
            ID_BD_CP0<=ID_BD;
        end
        else begin
            if(ID_we==1) begin
                if(ID_addr!=0)
                grf[ID_addr]<=ID_data;
            end
            ID_rs_base<=(ID_we==1&&ID_addr==ID_instr[`rs]&&ID_addr!=5'd0)?ID_data:grf[ID_instr[`rs]];//内部转发
            ID_rt<=(ID_we==1&&ID_addr==ID_instr[`rt]&&ID_addr!=5'd0)?ID_data:grf[ID_instr[`rt]];
            ID_instr_EX<=ID_instr;
            ID_pc_EX<=ID_pc;
            ID_exc_EX<=ID_exc;
            ID_BD_CP0<=ID_BD;
        end
    end

endmodule