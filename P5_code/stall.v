`include "const.v"
module stall(
    input [31:0] IF_instr_ID,
    input [31:0] ID_instr_EX,
    input [31:0] EX_instr_MEM,
    //input [31:0] MEM_instr_WB,
    output stall
);
    wire j_rs_D;//IF_ID
    wire j_rt_D;
    wire calr_D;
    wire cali_D;
    wire lw_D;
    wire sw_D;
    wire calr_E;//ID_EX
    wire cali_E;
    wire lw_E;
    wire sw_E;
    wire lw_M;

    assign j_rs_D=IF_instr_ID[`opcode]==`beq||(IF_instr_ID[`opcode]==6'b0&&IF_instr_ID[`func]==`jr);
    assign j_rt_D=IF_instr_ID[`opcode]==`beq;
    assign calr_D=IF_instr_ID[`opcode]==6'b0&&(IF_instr_ID[`func]==`add||IF_instr_ID[`func]==`sub);
    assign cali_D=IF_instr_ID[`opcode]==`ori||IF_instr_ID[`opcode]==`lui;
    assign lw_D=IF_instr_ID[`opcode]==`lw;
    assign sw_D=IF_instr_ID[`opcode]==`sw;
    assign calr_E=ID_instr_EX[`opcode]==6'b0&&(ID_instr_EX[`func]==`add||ID_instr_EX[`func]==`sub);
    assign cali_E=ID_instr_EX[`opcode]==`ori||ID_instr_EX[`opcode]==`lui;
    assign lw_E=ID_instr_EX[`opcode]==`lw;
    assign sw_E=ID_instr_EX[`opcode]==`sw;
    assign lw_M=EX_instr_MEM[`opcode]==`lw;




    wire j_rs_calr_EX;
    wire j_rs_cali_EX;
    wire j_rs_lw_EX;
    wire j_rs_jal_EX;
    wire j_rs_lw_MEM;
    wire j_rt_calr_EX;
    wire j_rt_cali_EX;
    wire j_rt_lw_EX;
    wire j_rt_jal_EX;
    wire j_rt_lw_MEM;

    // wire beq_calr_EX;
    // wire beq_cali_EX;
    // wire beq_lw_EX;
    // wire beq_jal_EX;
    // wire beq_lw_MEM;
    wire calr_lw_EX;
    wire cali_lw_EX;
    wire lw_lw_EX;
    wire sw_lw_EX;
    
    assign j_rs_calr_EX=j_rs_D&&calr_E&&(IF_instr_ID[`rs]==ID_instr_EX[`rd]);
    assign j_rs_cali_EX=j_rs_D&&cali_E&&(IF_instr_ID[`rs]==ID_instr_EX[`rt]);
    assign j_rs_lw_EX=j_rs_D&&lw_E&&(IF_instr_ID[`rs]==ID_instr_EX[`rt]);
    assign j_rs_jal_EX=j_rs_D&&ID_instr_EX[`opcode]==`jal&&(IF_instr_ID[`rs]==5'd31);
    assign j_rs_lw_MEM=j_rs_D&&lw_M&&(IF_instr_ID[`rs]==EX_instr_MEM[`rt]);

    assign j_rt_calr_EX=j_rt_D&&calr_E&&(IF_instr_ID[`rt]==ID_instr_EX[`rd]);
    assign j_rt_cali_EX=j_rt_D&&cali_E&&(IF_instr_ID[`rt]==ID_instr_EX[`rt]);
    assign j_rt_lw_EX=j_rt_D&&lw_E&&(IF_instr_ID[`rt]==ID_instr_EX[`rt]);
    assign j_rt_jal_EX=j_rt_D&&ID_instr_EX[`opcode]==`jal&&(IF_instr_ID[`rt]==5'd31);
    assign j_rt_lw_MEM=j_rt_D&&lw_M&&(IF_instr_ID[`rt]==EX_instr_MEM[`rt]);

    assign calr_lw_EX=calr_D&&lw_E&&
                        (IF_instr_ID[`rs]==ID_instr_EX[`rt]||IF_instr_ID[`rt]==ID_instr_EX[`rt]);
    assign cali_lw_EX=cali_D&&lw_E&&
                        (IF_instr_ID[`rs]==ID_instr_EX[`rt]);
    assign lw_lw_EX=lw_D&&lw_E&&
                        (IF_instr_ID[`base]==ID_instr_EX[`rt]);
    assign sw_lw_EX=sw_D&&lw_E&&
                        (IF_instr_ID[`rs]==ID_instr_EX[`rt]);

    assign stall=j_rs_calr_EX||
                j_rs_cali_EX||
                j_rs_lw_EX||
                j_rs_jal_EX||
                j_rs_lw_MEM||
                j_rt_calr_EX||
                j_rt_cali_EX||
                j_rt_lw_EX||
                j_rt_jal_EX||
                j_rt_lw_MEM||
                // beq_calr_EX||
                // beq_cali_EX||
                // beq_lw_EX||
                // beq_jal_EX||
                // beq_lw_MEM||
                calr_lw_EX||
                cali_lw_EX||
                lw_lw_EX||
                sw_lw_EX;

                

    // assign beq_calr_EX=IF_instr_ID[`opcode]==`beq&&ID_instr_EX[`opcode]==6'b0&&(ID_instr_EX[`func]==`add||ID_instr_EX[`func]==`sub)&&
    //                     (IF_instr_ID[`rs]==ID_instr_EX[`rd]||IF_instr_ID[`rt]==ID_instr_EX[`rd]);
    // assign beq_cali_EX=IF_instr_ID[`opcode]==`beq&&(ID_instr_EX[`opcode]==`ori||ID_instr_EX[`opcode]==`lui)&&
    //                     (IF_instr_ID[`rs]==ID_instr_EX[`rt]||IF_instr_ID[`rt]==ID_instr_EX[`rt]);
    // assign beq_lw_EX=IF_instr_ID[`opcode]==`beq&&ID_instr_EX[`opcode]==`lw&&
    //                     (IF_instr_ID[`rs]==ID_instr_EX[`rt]||IF_instr_ID[`rt]==ID_instr_EX[`rt]);
    // assign beq_jal_EX=IF_instr_ID[`opcode]==`beq&&ID_instr_EX[`opcode]==`jal&&
    //                     (IF_instr_ID[`rs]==6'd31||IF_instr_ID[`rt]==6'd31);
    // assign beq_lw_MEM=IF_instr_ID[`opcode]==`beq&&EX_instr_MEM[`opcode]==`lw&&
    //                     (IF_instr_ID[`rs]==EX_instr_MEM[`rt]||IF_instr_ID[`rt]==EX_instr_MEM[`rt]);

endmodule