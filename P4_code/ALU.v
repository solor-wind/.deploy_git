`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:54:44 10/31/2023 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
    input [1:0] op,
    input [31:0] a,
    input [31:0] b,
    output [31:0] out
    );
assign out=(op==2'b0)?(a+b):
				(op==2'b1)?(a-b):
				(op==2'b10)?(a|b):
				(a>b)?32'b1:
				(a==b)?32'b0:-1;
endmodule
