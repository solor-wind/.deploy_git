`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:19:18 10/31/2023 
// Design Name: 
// Module Name:    controller 
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
module controller(
    input [31:0] Instr,
    output [1:0] ctrl,
    output WE,
    output [1:0] GRF_op1,
    output [1:0] GRF_op2,
    output [1:0] op,
    output [1:0] ALU_op,
    output MemWrite,
    input [31:0] ALU_out
    );
	 wire [15:0] im_of;
	 wire [5:0] Func;
	 wire [4:0] rd;
	 wire [4:0] rt;
	 wire [4:0] rs_base;
	 wire [5:0] Op_code;
	 
assign im_of=Instr[15:0];
assign Func=Instr[5:0];
assign rd=Instr[15:11];
assign rt=Instr[20:16];
assign rs_base=Instr[25:21];
assign Op_code=Instr[31:26];

wire add,sub,ori,lw,sw,beq,lui,jal,jr;
assign add=(Op_code==6'b000000&&Func==6'b100000);
assign sub=(Op_code==6'b000000&&Func==6'b100010);
assign ori=(Op_code==6'b001101);
assign lw=(Op_code==6'b100011);
assign sw=(Op_code==6'b101011);
assign beq=(Op_code==6'b000100);
assign lui=(Op_code==6'b001111);
assign jal=(Op_code==6'b000011);
assign jr=(Op_code==6'b000000&&Func==6'b001000);


assign ctrl=(beq&&ALU_out==0)?1:
				(jal)?2:
				(jr)?3:0;
assign WE=(add||sub||ori||lw||lui||jal);
assign GRF_op1=(ori||lw||lui)?1://rt
					(jal)?2:0;//$ra
assign GRF_op2=(jal)?3:
					(lui)?2:
					(lw)?1:0;
assign op=(beq)?3:
				(ori)?2:
				(sub)?1:0;
assign ALU_op=(lw||sw)?2:
					(ori||lui)?1:0;
assign MemWrite=(sw);
endmodule
