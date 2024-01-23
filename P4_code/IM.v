`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:40:42 10/31/2023 
// Design Name: 
// Module Name:    IM 
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
module IM(
    input [31:0] addr,
    output [31:0] Instr
    );
	wire [11:0] addr2;
	reg [31:0] IM [0:4095];
	assign addr2=addr[13:2]-12'b1100_0000_0000;
	assign Instr=IM[addr2];
	initial begin
	      $readmemh("code.txt", IM); 
	end
endmodule
