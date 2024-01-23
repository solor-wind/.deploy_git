`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:48:25 10/31/2023 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
    input clk,
    input rst,
    input WE,
    input [4:0] RegAddr,
    input [31:0] WD,
    input [4:0] A1,
    input [4:0] A2,
    output [31:0] RD,
    output [31:0] RD2
    );
	 reg [31:0] grf [0:31];
	 integer i;
always@(posedge clk)begin
	if(rst==1)begin
		for(i=0;i<32;i=i+1)begin
			grf[i]<=32'b0;
			end
		end
	else begin
		if(WE==1&&RegAddr!=0)begin
			grf[RegAddr]<=WD;
			end
		end
end
assign RD=grf[A1];
assign RD2=grf[A2];
endmodule
