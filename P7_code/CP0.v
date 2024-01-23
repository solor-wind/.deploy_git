`include "const.v"
module CP0 (
    input clk,
    input rst,
    input [5:0] HWint,//输入中断信号？
    input [31:0] exc,//异常类型
    input [31:0] EX_pc,
    input [31:0] EX_instr,
    input BD,
    input [31:0] MEM_instr,//判断是否是延迟槽指令
    input [31:0] EX_rt,
    output [31:0] CP0_rd,
    output reg [31:0] EPC,//$14
    output Req
);
    //即时给出中断信号，但写寄存器要延时？
    reg [31:0] SR;//$12
    reg [31:0] Cause;//$13

    assign Req=(exc||((HWint&SR[`IM])&&SR[`IE]))&&(!SR[`EXL]);//内部异常、外部中断(且允许)、没有正在中断、允许全局中断
    assign CP0_rd=(EX_instr[`rd]==12)?{16'b0,SR[15:10],8'b0,SR[1:0]}:
                    (EX_instr[`rd]==13)?{Cause[31],15'b0,Cause[15:10],3'b0,Cause[6:2],2'b0}:
                    (EX_instr[`rd]==14)?EPC:0;

    always@(posedge clk) begin
        if(rst==1)begin
            EPC<=32'h0000;
            SR<=0;
            Cause<=0;
        end
        else begin
            Cause[`IP]<=HWint;
            if(Req&&!SR[`EXL]) begin//发生异常时
                SR[`EXL]<=1;
                Cause[`BD]<=BD;//&&!(HWint&SR[`IM]);
                //Cause[`IP]<=HWint;
                Cause[`Exc]<=((HWint&SR[`IM])&&SR[`IE])?0:exc;
                EPC<=BD?EX_pc-4:EX_pc;//空泡？
            end
            else if(EX_instr[`opcode]==6'b010000&&EX_instr[25:21]==`mtc0)begin
                case (EX_instr[`rd])
                    12:begin
                        SR[15:10]<=EX_rt[15:10];//SR<=EX_rt;
                        SR[1:0]<=EX_rt[1:0];
                    end
                    13:Cause<=EX_rt;//保证不向Cause写入？
                    14:EPC<=EX_rt;
                    default: ;
                endcase
            end
            // else if(EX_instr[`opcode]==`mfc0)begin
            //     case (EX_instr[`rt])
            //         12:CP0_rd<=SR;
            //         13:CP0_rd<=Cause;
            //         14:CP0_rd<=EPC;
            //     endcase
            // end
            else if(EX_instr[`opcode]==6'b010000&&EX_instr[`func]==`eret)begin
                SR[`EXL]<=0;//允许中断
            end
        end
    end
endmodule