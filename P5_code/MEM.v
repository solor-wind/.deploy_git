`include "const.v"
module MEM (
    input clk,
    input rst,
    input [31:0] MEM_pc,
    input [31:0] MEM_instr,
    input [31:0] MEM_addr,
    input [31:0] MEM_data,
    output reg [31:0] MEM_data_WB,
    output reg [31:0] EX_data_WB,
    output reg [31:0] MEM_instr_WB,
    output reg [31:0] MEM_pc_WB
);
    reg [31:0] DM [0:3071];
    integer i;
    always@(posedge clk) begin
        if(rst==1) begin
            for(i=0;i<3072;i=i+1) begin
                DM[i]<=0;
            end
            MEM_data_WB<=0;
            EX_data_WB<=0;
            MEM_instr_WB<=0;
            MEM_pc_WB<=0;
        end
        else begin
            if(MEM_instr[`opcode]==`sw) begin
                DM[MEM_addr[13:2]]<=MEM_data;
                $display("%d@%h: *%h <= %h", $time, MEM_pc, MEM_addr,MEM_data);
            end
            MEM_data_WB<=DM[MEM_addr[13:2]];
            EX_data_WB<=MEM_addr;
            MEM_instr_WB<=MEM_instr;
            MEM_pc_WB<=MEM_pc;
        end
    end
endmodule