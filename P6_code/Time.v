`include "const.v"
module Time (
    input [31:0] instr,
    output [31:0] use_new
);
//对应数据段全1代表use，否则代表use/new的时间
//[2]0代表rs_use，1代表rs_new//默认为0，use高达31，不会阻塞
//rs没有new，rd没有use
//jal特判
//mfhi和mflo特判
    assign use_new[`rs]=(instr[`opcode]==`beq||
                         instr[`opcode]==`bne||
                         instr[`opcode]==6'b0&&instr[`func]==`jr)?5'b0://rs_use=0
                         ((instr[`opcode]==6'b0&&(instr[`func]==`add||
                                                 instr[`func]==`sub||
                                                 instr[`func]==`and||
                                                 instr[`func]==`or||
                                                 instr[`func]==`slt||
                                                 instr[`func]==`sltu||
                                                 instr[`func]==`mult||
                                                 instr[`func]==`multu||
                                                 instr[`func]==`div||
                                                 instr[`func]==`divu||
                                                 instr[`func]==`mthi||
                                                 instr[`func]==`mtlo))||
                        instr[`opcode]==`ori||
                        instr[`opcode]==`andi||
                        instr[`opcode]==`addi||
                        instr[`opcode]==`lw||
                        instr[`opcode]==`sw||
                        instr[`opcode]==`lb||
                        instr[`opcode]==`sb||
                        instr[`opcode]==`lh||
                        instr[`opcode]==`sh)?5'b1:5'b11111;//rs_use=1
    assign use_new[2]=(instr[`opcode]==`beq||
                         instr[`opcode]==`bne||
                         instr[`opcode]==6'b0&&instr[`func]==`jr)?0://rs_use=0
                         ((instr[`opcode]==6'b0&&(instr[`func]==`add||
                                                 instr[`func]==`sub||
                                                 instr[`func]==`and||
                                                 instr[`func]==`or||
                                                 instr[`func]==`slt||
                                                 instr[`func]==`sltu||
                                                 instr[`func]==`mult||
                                                 instr[`func]==`multu||
                                                 instr[`func]==`div||
                                                 instr[`func]==`divu||
                                                 instr[`func]==`mthi||
                                                 instr[`func]==`mtlo))||
                        instr[`opcode]==`ori||
                        instr[`opcode]==`andi||
                        instr[`opcode]==`addi||
                        instr[`opcode]==`lw||
                        instr[`opcode]==`sw||
                        instr[`opcode]==`lb||
                        instr[`opcode]==`sb||
                        instr[`opcode]==`lh||
                        instr[`opcode]==`sh)?0:0;//rs_use=1

    assign use_new[`rt]=(instr[`opcode]==`beq||
                         instr[`opcode]==`bne)?5'b0://rt_use=0
                         (instr[`opcode]==6'b0&&(instr[`func]==`add||
                                                 instr[`func]==`sub||
                                                 instr[`func]==`and||
                                                 instr[`func]==`or||
                                                 instr[`func]==`slt||
                                                 instr[`func]==`sltu||
                                                 instr[`func]==`mult||
                                                 instr[`func]==`multu||
                                                 instr[`func]==`div||
                                                 instr[`func]==`divu))?5'b00001://rt_use=1
                        (instr[`opcode]==`sw||
                        instr[`opcode]==`sb||
                        instr[`opcode]==`sh)?5'b00010://rt_use=2
                        (instr[`opcode]==`lui||
                        instr[`opcode]==`ori||
                        instr[`opcode]==`andi||
                        instr[`opcode]==`addi)?5'b00001://rt_new=1
                        (instr[`opcode]==`lw||
                        instr[`opcode]==`lh||
                        instr[`opcode]==`lb)?5'b00010:5'b11111;//rt_new=2
    assign use_new[1]=(instr[`opcode]==`beq||
                         instr[`opcode]==`bne)?0://rt_use=0
                         (instr[`opcode]==6'b0&&(instr[`func]==`add||
                                                 instr[`func]==`sub||
                                                 instr[`func]==`and||
                                                 instr[`func]==`or||
                                                 instr[`func]==`slt||
                                                 instr[`func]==`sltu||
                                                 instr[`func]==`mult||
                                                 instr[`func]==`multu||
                                                 instr[`func]==`div||
                                                 instr[`func]==`divu))?0://rt_use=1
                        (instr[`opcode]==`sw||
                        instr[`opcode]==`sb||
                        instr[`opcode]==`sh)?0://rt_use=2
                        (instr[`opcode]==`lui||
                        instr[`opcode]==`ori||
                        instr[`opcode]==`andi||
                        instr[`opcode]==`addi)?1://rt_new=1
                        (instr[`opcode]==`lw||
                        instr[`opcode]==`lh||
                        instr[`opcode]==`lb)?1:0;//rt_new=2
    
    assign use_new[`rd]=(instr[`opcode]==6'b0&&(instr[`func]==`add||
                                                instr[`func]==`sub||
                                                instr[`func]==`and||
                                                instr[`func]==`or||
                                                instr[`func]==`slt||
                                                instr[`func]==`sltu||
                                                instr[`func]==`mfhi||
                                                instr[`func]==`mflo))?5'b00001:5'b11111;//rd_new=1
    assign use_new[0]=(instr[`opcode]==6'b0&&(instr[`func]==`add||
                                                instr[`func]==`sub||
                                                instr[`func]==`and||
                                                instr[`func]==`or||
                                                instr[`func]==`slt||
                                                instr[`func]==`sltu||
                                                instr[`func]==`mfhi||
                                                instr[`func]==`mflo))?1:0;//rd_new=1

    assign use_new[4]=(instr[`opcode]==6'b0&&(instr[`func]==`mult||
                                                instr[`func]==`multu||
                                                instr[`func]==`div||
                                                instr[`func]==`divu));//hi/lo_new=10
endmodule