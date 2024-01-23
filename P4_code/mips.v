`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:36:34 10/31/2023 
// Design Name: 
// Module Name:    mips 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mips(
    input clk,
    input reset
    );

//CON
wire [31:0] Instr;
wire [1:0] j_ctrl;//跳转指令，0为正常+4  1为beq  2为jal  3为jr
wire grf_write;//grf写入信号
wire [1:0] grf_reg;//选择grf写入的寄存器
wire [1:0] grf_data;//选择grf写入数据来源
wire [1:0] ALU_op;//运算选择
wire [1:0] ALU_data_op;//运算数选择
wire MemWrite;//数据写入信号
//PC
wire [31:0] j_addr;//PC跳转地址
wire [31:0] pc;//PC
//ALU
wire [31:0] ALU_out;//ALU运算结果
//reg
wire [4:0] RegAddr;//写入的寄存器
wire [31:0] WD;//写入的数据
wire [31:0] RD1;//读出的寄存器数据1
wire [31:0] RD2;//读出的寄存器数据2
//ALU
wire [31:0] b;//运算数2
//DM
wire [31:0] DM_out;//DM读出的数据
//decode
	 wire [15:0] im_of;
	 wire [5:0] Func;
	 wire [4:0] rd;
	 wire [4:0] rt;
	 wire [4:0] rs_base;
	 wire [5:0] Op_code;
	 wire [25:0] index;
assign im_of=Instr[15:0];
assign Func=Instr[5:0];
assign rd=Instr[15:11];
assign rt=Instr[20:16];
assign rs_base=Instr[25:21];
assign Op_code=Instr[31:26];
assign index=Instr[25:0];


assign j_addr=(j_ctrl==2'b00)?(pc+4):
					(j_ctrl==2'b01)?(pc+4+{{14{im_of[15]}},im_of,2'b0})://beq
					(j_ctrl==2'b10)?({pc[31:28],index,2'b0})://jal
					RD1;//jr
assign RegAddr=(grf_reg==2'b00)?rd:
					(grf_reg==2'b01)?rt:
					5'b11111;//写入$ra
assign WD=(grf_data==2'b00)?ALU_out:
				(grf_data==2'b01)?DM_out://lw
				(grf_data==2'b10)?{im_of,{16{1'b0}}}://lui
				pc+4;//写入$ra
assign b=(ALU_data_op==0)?RD2:
			(ALU_data_op==1)?{{16{1'b0}},im_of}://ori
			{{16{im_of[15]}},im_of};//lw,sw

controller con(Instr,j_ctrl,grf_write,grf_reg,grf_data,ALU_op,ALU_data_op,MemWrite,ALU_out);
PC Pc(clk,reset,j_addr,pc);
IM im(pc,Instr);
GRF grf(clk,reset,grf_write,RegAddr,WD,rs_base,rt,RD1,RD2);
ALU alu(ALU_op,RD1,b,ALU_out);
DM dm(clk,reset,MemWrite,ALU_out,RD2,DM_out);

always@(posedge clk)begin
	if(grf_write==1&&reset!=1)begin
		$display("@%h: $%d <= %h", pc, RegAddr, WD);
		end
	if(MemWrite==1&&reset!=1)begin
		$display("@%h: *%h <= %h", pc, ALU_out, RD2);
		end
end
/*
integer fp;
initial begin
	
fp = $fopen("info.txt","w");
end
*/

endmodule
