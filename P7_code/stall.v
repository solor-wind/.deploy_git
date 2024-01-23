`include "const.v"
module stall(
    input [31:0] IF_instr_ID,
    input [31:0] ID_instr_EX,
    input [31:0] EX_instr_MEM,
    input busy,
    output stall
);
    wire [31:0] D_time;
    wire [31:0] E_time;
    wire [31:0] M_tmp_time;
    wire [31:0] M_time;
    Time ID_time(
        .instr(IF_instr_ID),
        .use_new(D_time)
    );
    Time EX_time(
        .instr(ID_instr_EX),
        .use_new(E_time)
    );
    Time MEM_time(
        .instr(EX_instr_MEM),
        .use_new(M_tmp_time)
    );
    assign M_time[`rd]=(!M_tmp_time[0])?M_tmp_time[`rd]:
                        (M_tmp_time[`rd]>0)?M_tmp_time[`rd]-1:5'b0;
    assign M_time[`rt]=(!M_tmp_time[1])?M_tmp_time[`rt]:
                        (M_tmp_time[`rt]>0)?M_tmp_time[`rt]-1:5'b0;
    assign M_time[`rs]=M_tmp_time[`rs];
    assign M_time[4:0]=M_tmp_time[4:0];

    assign stall=(!D_time[2]&&(((E_time[2])&&(IF_instr_ID[`rs]==ID_instr_EX[`rs])&&(D_time[`rs]<E_time[`rs]))||
                                ((E_time[1])&&(IF_instr_ID[`rs]==ID_instr_EX[`rt])&&(D_time[`rs]<E_time[`rt]))||
                                ((E_time[0])&&(IF_instr_ID[`rs]==ID_instr_EX[`rd])&&(D_time[`rs]<E_time[`rd])))    )||//rs
                (!D_time[1]&&(((E_time[2])&&(IF_instr_ID[`rt]==ID_instr_EX[`rs])&&(D_time[`rt]<E_time[`rs]))||
                                ((E_time[1])&&(IF_instr_ID[`rt]==ID_instr_EX[`rt])&&(D_time[`rt]<E_time[`rt]))||
                                ((E_time[0])&&(IF_instr_ID[`rt]==ID_instr_EX[`rd])&&(D_time[`rt]<E_time[`rd])))    )||
                (!D_time[2]&&(((M_time[2])&&(IF_instr_ID[`rs]==EX_instr_MEM[`rs])&&(D_time[`rs]<M_time[`rs]))||
                                ((M_time[1])&&(IF_instr_ID[`rs]==EX_instr_MEM[`rt])&&(D_time[`rs]<M_time[`rt]))||
                                ((M_time[0])&&(IF_instr_ID[`rs]==EX_instr_MEM[`rd])&&(D_time[`rs]<M_time[`rd])))   )||//rs
                (!D_time[1]&&(((M_time[2])&&(IF_instr_ID[`rt]==EX_instr_MEM[`rs])&&(D_time[`rt]<M_time[`rs]))||
                                ((M_time[1])&&(IF_instr_ID[`rt]==EX_instr_MEM[`rt])&&(D_time[`rt]<M_time[`rt]))||
                                ((M_time[0])&&(IF_instr_ID[`rt]==EX_instr_MEM[`rd])&&(D_time[`rt]<M_time[`rd])))   )||
                (D_time[`rt]==0&&ID_instr_EX[`opcode]==`jal&&IF_instr_ID[`rt]==31)||
                (D_time[`rs]==0&&ID_instr_EX[`opcode]==`jal&&IF_instr_ID[`rs]==31)||
                (IF_instr_ID[`opcode]==0&&(IF_instr_ID[`func]==`mult||
                                            IF_instr_ID[`func]==`multu||
                                            IF_instr_ID[`func]==`div||
                                            IF_instr_ID[`func]==`divu||
                                            IF_instr_ID[`func]==`mfhi||
                                            IF_instr_ID[`func]==`mflo||
                                            IF_instr_ID[`func]==`mthi||
                                            IF_instr_ID[`func]==`mtlo)
                                        &&(E_time[4]||busy));
                //(IF_instr_ID[`opcode]==6'b010000&&IF_instr_ID[`func]==`eret&&ID_instr_EX[`opcode]==6'b010000&&ID_instr_EX[25:21]==`mtc0&&ID_instr_EX[`rd]==14);


endmodule