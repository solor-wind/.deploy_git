`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:02:18 10/31/2023 
// Design Name: 
// Module Name:    DM 
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
module DM(
    input clk,
    input rst,
    input MemWrite,
    input [31:0] MemAddr,
    input [31:0] MemDataIn,
    output [31:0] MemDataOut
    );
	 reg [31:0] DM [0:3071];
	 integer i;
always@(posedge clk)begin
	if(rst==1)begin
		for(i=0;i<3072;i=i+1)begin
			DM[i]<=32'b0;
			end
		//$readmemh("DM.txt", DM, 0, 3071);
		end
	else begin
		if(MemWrite==1'b1) begin
			DM[MemAddr[13:2]]<=MemDataIn;
			end
		end
end
assign MemDataOut=DM[MemAddr[13:2]];
endmodule
