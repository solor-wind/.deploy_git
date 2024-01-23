`include "const.v"
module IF(
    input clk,
    input rst,
    input req,//中断信号
    input stall,
    input [2:0] IF_j,
    input [31:0] IF_pc4,
    output reg [31:0] IF_pc_ID,
    output reg [31:0] IF_instr_ID,
    output reg IF_BD_ID,
    output [31:0] IF_exc_ID,//异常信号
    
    input [31:0] IF_instr,
    output reg [31:0] IF_pc
);
    always@(posedge clk) begin
        if(rst==1)begin
            IF_pc<=32'h3000;
            IF_pc_ID<=32'h3000;
            IF_instr_ID<=0;
            IF_BD_ID<=0;
        end
        else if(req==1) begin//中断
            IF_pc<=32'h4180;
            IF_pc_ID<=32'h4180;//保证了异常处理不会嵌套中断，因此这样操作宏观pc无事
            IF_instr_ID<=0;
            IF_BD_ID<=0;
        end
        else if(stall==0) begin
            if(IF_j!=0)
                IF_pc<=IF_pc4;
            else
                IF_pc<=IF_pc+4;
            
            if(IF_j==5)begin
                IF_pc_ID<=IF_pc4;
                IF_instr_ID<=0;//eret没有延迟槽
            end
            else begin
                IF_BD_ID<=(IF_instr_ID[`opcode]==`beq||
                            IF_instr_ID[`opcode]==`bne||
                            IF_instr_ID[`opcode]==`jal||
                            (IF_instr_ID[`opcode]==0&&IF_instr_ID[`func]==`jr));
                IF_pc_ID<=IF_pc;//延迟槽
                IF_instr_ID<=IF_instr;
            end
        end
    end
    assign IF_exc_ID=(IF_pc_ID[1:0]||IF_pc_ID<32'h3000||IF_pc_ID>32'h6ffc)?4:
                    (IF_instr_ID[`opcode]==0&&IF_instr_ID[`func]==`syscall)?8:
                    (!((IF_instr_ID[`opcode]==0&&(IF_instr_ID[`func]==`add||
                                                IF_instr_ID[`func]==`sub||
                                                IF_instr_ID[`func]==`and||
                                                IF_instr_ID[`func]==`or||
                                                IF_instr_ID[`func]==`slt||
                                                IF_instr_ID[`func]==`sltu||
                                                IF_instr_ID[`func]==`mult||
                                                IF_instr_ID[`func]==`multu||
                                                IF_instr_ID[`func]==`div||
                                                IF_instr_ID[`func]==`divu||
                                                IF_instr_ID[`func]==`mfhi||
                                                IF_instr_ID[`func]==`mflo||
                                                IF_instr_ID[`func]==`mthi||
                                                IF_instr_ID[`func]==`mtlo||
                                                IF_instr_ID[`func]==`jr||
                                                IF_instr_ID[`func]==`syscall))||
                    (IF_instr_ID[`opcode]==6'b010000&&(IF_instr_ID[25:21]==`mfc0||
                                                        IF_instr_ID[25:21]==`mtc0||
                                                        IF_instr_ID[5:0]==`eret))||
                    (IF_instr_ID[`opcode]==`lui||
                    IF_instr_ID[`opcode]==`ori||
                    IF_instr_ID[`opcode]==`andi||
                    IF_instr_ID[`opcode]==`addi||
                    IF_instr_ID[`opcode]==`lw||
                    IF_instr_ID[`opcode]==`lh||
                    IF_instr_ID[`opcode]==`lb||
                    IF_instr_ID[`opcode]==`sw||
                    IF_instr_ID[`opcode]==`sh||
                    IF_instr_ID[`opcode]==`sb||
                    IF_instr_ID[`opcode]==`beq||
                    IF_instr_ID[`opcode]==`bne||
                    IF_instr_ID[`opcode]==`jal||
                    IF_instr_ID==0)))?10:0;
endmodule