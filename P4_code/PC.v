`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:06:48 10/31/2023 
// Design Name: 
// Module Name:    PC 
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
module PC(
    input clk,
    input rst,
    input [31:0] j_addr,
    output [31:0] addr
    );
	 reg [31:0] PC;
always@(posedge clk)begin
	if(rst==1)begin
		PC<=32'h3000;
		end
	else begin
		PC<=j_addr;
		end
end
assign addr=PC;
endmodule
