module IF(
    input clk,
    input rst,
    input stall,
    input [2:0] IF_j,
    input [31:0] IF_pc4,
    output reg [31:0] IF_pc_ID,
    output reg [31:0] IF_instr_ID
);
    reg [31:0] IM [0:4095];//存储指令
    reg [31:0] IF_pc;//存储pc，同时也是当前的pc
    wire [31:0] IF_instr;//当前的指令
    wire [31:0] pc_addr;//方便截取特定位宽
    assign pc_addr=IF_pc-32'h3000;
    assign IF_instr=IM[pc_addr[13:2]];

    always@(posedge clk) begin
        if(rst==1)begin
            IF_pc<=32'h3000;
            IF_pc_ID<=32'h3000;
            IF_instr_ID<=0;
        end
        else if(stall==0) begin
            if(IF_j!=0)
                IF_pc<=IF_pc4;
            else
                IF_pc<=IF_pc+4;
            IF_pc_ID<=IF_pc;//延迟槽？
            IF_instr_ID<=IF_instr;
        end
    end
    initial begin
        $readmemh("code.txt",IM);
    end
endmodule