`include "const.v"
module mips(
    input clk,
    input reset
);
    wire stall;

    //转发相关
    wire ID_j_rs;
    wire ID_j_rt;
    wire EX_calr;
    wire EX_cali;
    wire EX_lw;
    wire EX_sw;
    wire MEM_calr;
    wire MEM_cali;
    wire MEM_sw;
    wire MEM_jal;
    assign ID_j_rs=IF_instr_ID[`opcode]==`beq||(IF_instr_ID[`opcode]==6'b0&&IF_instr_ID[`func]==`jr);
    assign ID_j_rt=IF_instr_ID[`opcode]==`beq;
    assign EX_calr=ID_instr_EX[`opcode]==6'b0&&(ID_instr_EX[`func]==`add||ID_instr_EX[`func]==`sub);//指令后移？
    assign EX_cali=ID_instr_EX[`opcode]==`ori||ID_instr_EX[`opcode]==`lui;
    assign EX_lw=ID_instr_EX[`opcode]==`lw;
    assign EX_sw=ID_instr_EX[`opcode]==`sw;
    assign MEM_calr=EX_instr_MEM[`opcode]==6'b0&&(EX_instr_MEM[`func]==`add||EX_instr_MEM[`func]==`sub);
    assign MEM_cali=EX_instr_MEM[`opcode]==`ori||EX_instr_MEM[`opcode]==`lui;
    assign MEM_sw=EX_instr_MEM[`opcode]==`sw;
    assign MEM_jal=EX_instr_MEM[`opcode]==`jal;

    wire [31:0] EX_rs_base;
    wire [31:0] EX_rt_use;
    wire [31:0] MEM_data;
    wire [2:0] ID_rs_sign;
    wire [31:0] ID_rs_data;
    wire [2:0] ID_rt_sign;
    wire [31:0] ID_rt_data;
    assign EX_rs_base=(ID_instr_EX[`rs]==5'd0)?ID_rs_base_EX:
                        (EX_calr||EX_cali||EX_lw||EX_sw)&&((MEM_calr&&ID_instr_EX[`rs]==EX_instr_MEM[`rd])||(MEM_cali&&ID_instr_EX[`rs]==EX_instr_MEM[`rt])||(MEM_jal&&ID_instr_EX[`rs]==5'd31))?EX_out://从M级（EX/MEM）转发
                        (EX_calr||EX_cali||EX_lw||EX_sw)&&(WB_we_ID&&ID_instr_EX[`rs]==WB_addr_ID)?WB_data_ID:ID_rs_base_EX;//W级转发
    assign EX_rt_use=(ID_instr_EX[`rt]==5'd0)?ID_rt_EX:
                    EX_calr&&((MEM_calr&&ID_instr_EX[`rt]==EX_instr_MEM[`rd])||(MEM_cali&&ID_instr_EX[`rt]==EX_instr_MEM[`rt])||(MEM_jal&&ID_instr_EX[`rt]==5'd31))?EX_out://从M级（EX/MEM）转发
                    EX_calr&&(WB_we_ID&&ID_instr_EX[`rt]==WB_addr_ID)?WB_data_ID:ID_rt_EX;//W级转发
    assign MEM_data=(EX_instr_MEM[`rt]==5'd0)?EX_rt_MEM:
                    MEM_sw&&(WB_we_ID&&EX_instr_MEM[`rt]==WB_addr_ID)?WB_data_ID:EX_rt_MEM;//W级转发
    assign ID_rs_sign=(IF_instr_ID[`rs]==5'd0)?0:
                        ID_j_rs&&((MEM_calr&&IF_instr_ID[`rs]==EX_instr_MEM[`rd])||(MEM_cali&&IF_instr_ID[`rs]==EX_instr_MEM[`rt])||(MEM_jal&&IF_instr_ID[`rs]==5'd31))?1:0;//从M级（EX/MEM）转发
    assign ID_rs_data=(ID_rs_sign==1)?EX_out:0;
    assign ID_rt_sign=(IF_instr_ID[`rt]==5'd0)?0:
                        ID_j_rt&&((MEM_calr&&IF_instr_ID[`rt]==EX_instr_MEM[`rd])||(MEM_cali&&IF_instr_ID[`rt]==EX_instr_MEM[`rt])||(MEM_jal&&IF_instr_ID[`rt]==5'd31))?1:0;//从M级（EX/MEM）转发
    assign ID_rt_data=(ID_rt_sign==1)?EX_out:0;
    

    
    //模块间的连接
    wire [31:0] ID_pc_IF;
    wire [2:0] ID_j_IF;
    wire [31:0] IF_instr_ID;
    wire [31:0] IF_pc_ID;

    wire [31:0] ID_instr_EX;
    wire [31:0] ID_rs_base_EX;
    wire [31:0] ID_rt_EX;
    wire [31:0] ID_pc_EX;

    wire [31:0] EX_instr_MEM;
    wire [31:0] EX_out;
    wire [31:0] EX_rt_MEM;
    wire [31:0] EX_pc_MEM;
    wire [31:0] EX_rt_sw;
    assign EX_rt_sw=EX_sw&&WB_we_ID&&(WB_addr_ID==ID_instr_EX[`rt]&&WB_addr_ID!=5'd0)?WB_data_ID:ID_rt_EX;

    wire [31:0] MEM_data_WB;
    wire [31:0] EX_data_WB;
    wire [31:0] MEM_instr_WB;
    wire [31:0] MEM_pc_WB;

    wire WB_we_ID;
    wire [4:0] WB_addr_ID;
    wire [31:0] WB_data_ID;
    wire [31:0] WB_pc_ID;
    IF fetch(
        .clk(clk),
        .rst(reset),
        .stall(stall),
        .IF_j(ID_j_IF),
        .IF_pc4(ID_pc_IF),
        .IF_pc_ID(IF_pc_ID),
        .IF_instr_ID(IF_instr_ID)
    );

    ID decode(
        .clk(clk),
        .rst(reset),
        .stall(stall),
        .ID_pc(IF_pc_ID),
        .ID_instr(IF_instr_ID),
        .WB_pc_ID(WB_pc_ID),
        .ID_we(WB_we_ID),
        .ID_addr(WB_addr_ID),
        .ID_data(WB_data_ID),

        .ID_rs_sign(ID_rs_sign),
        .ID_rt_sign(ID_rt_sign),
        .ID_rs_data(ID_rs_data),
        .ID_rt_data(ID_rt_data),

        .ID_rs_base(ID_rs_base_EX),
        .ID_rt(ID_rt_EX),
        .ID_j_IF(ID_j_IF),
        .ID_pc_IF(ID_pc_IF),
        .ID_instr_EX(ID_instr_EX),
        .ID_pc_EX(ID_pc_EX)
    );
    
    EX execute(
        .clk(clk),
        .rst(reset),
        .EX_pc(ID_pc_EX),
        .EX_instr(ID_instr_EX),
        .EX_rs_base(EX_rs_base),
        .EX_rt_use(EX_rt_use),
        .EX_rt(EX_rt_sw),
        .EX_out(EX_out),
        .EX_rt_MEM(EX_rt_MEM),
        .EX_instr_MEM(EX_instr_MEM),
        .EX_pc_MEM(EX_pc_MEM)
    );
    
    MEM memory(
        .clk(clk),
        .rst(reset),
        .MEM_pc(EX_pc_MEM),
        .MEM_instr(EX_instr_MEM),
        .MEM_addr(EX_out),
        .MEM_data(MEM_data),
        .MEM_data_WB(MEM_data_WB),
        .EX_data_WB(EX_data_WB),
        .MEM_instr_WB(MEM_instr_WB),
        .MEM_pc_WB(MEM_pc_WB)
    );
    
    WB writeback(
        .clk(clk),
        .rst(reset),
        .WB_pc(MEM_pc_WB),
        .WB_instr(MEM_instr_WB),
        .WB_lw_data(MEM_data_WB),
        .WB_alu_data(EX_data_WB),
        .WB_we_ID(WB_we_ID),
        .WB_addr_ID(WB_addr_ID),
        .WB_data_ID(WB_data_ID),
        .WB_pc_ID(WB_pc_ID)
    );
    
    stall staller(
        .IF_instr_ID(IF_instr_ID),
        .ID_instr_EX(ID_instr_EX),
        .EX_instr_MEM(EX_instr_MEM),
        .stall(stall)
    );
endmodule

    // wire ID_beq;
    // wire ID_jr;
    // wire EX_calr;
    // wire EX_cali;
    // wire EX_lw;
    // wire EX_sw;
    // wire MEM_calr;
    // wire MEM_cali;
    // wire MEM_lw;
    // wire MEM_sw;
    // wire MEM_jal;
    // wire WB_calr;
    // wire WB_cali;
    // wire WB_lw;
    // wire WB_sw;
    // wire WB_jal;
    // assign ID_beq=IF_instr_ID[`opcode]==`beq||;
    // assign ID_jr=IF_instr_ID[`opcode]==6'b0&&IF_instr_ID[`func]==`jr;
    // assign EX_calr=ID_instr_EX[`opcode]==6'b0&&(ID_instr_EX[`func]==`add||ID_instr_EX[`func]==`sub);//指令后移？
    // assign EX_cali=ID_instr_EX[`opcode]==`ori||ID_instr_EX[`opcode]==`lui;
    // assign EX_lw=ID_instr_EX[`opcode]==`lw;
    // assign EX_sw=ID_instr_EX[`opcode]==`sw;
    // assign MEM_calr=EX_instr_MEM[`opcode]==6'b0&&(EX_instr_MEM[`func]==`add||EX_instr_MEM[`func]==`sub);
    // assign MEM_cali=EX_instr_MEM[`opcode]==`ori||EX_instr_MEM[`opcode]==`lui;
    // assign MEM_lw=EX_instr_MEM[`opcode]==`lw;
    // assign MEM_sw=EX_instr_MEM[`opcode]==`sw;
    // assign MEM_jal=EX_instr_MEM[`opcode]==`jal;
    // assign WB_calr=MEM_instr_WB[`opcode]==6'b0&&(MEM_instr_WB[`func]==`add||MEM_instr_WB[`func]==`sub);
    // assign WB_cali=MEM_instr_WB[`opcode]==`ori||MEM_instr_WB[`opcode]==`lui;
    // assign WB_lw=MEM_instr_WB[`opcode]==`lw;
    // assign WB_sw=MEM_instr_WB[`opcode]==`sw;
    // assign WB_jal=MEM_instr_WB[`opcode]==`jal;

    // assign EX_rs_base=(ID_instr_EX[`rs]==5'd0)?ID_rs_base_EX:
    //                     (EX_calr||EX_cali||EX_lw||EX_sw)&&((MEM_calr&&ID_instr_EX[`rs]==EX_instr_MEM[`rd])||(MEM_cali&&ID_instr_EX[`rs]==EX_instr_MEM[`rt])||(MEM_jal&&ID_instr_EX[`rs]==5'd31))?EX_out://从M级（EX/MEM）转发
    //                     (EX_calr||EX_cali||EX_lw||EX_sw)&&(WB_we_ID&&ID_instr_EX[`rs]==WB_addr_ID)?WB_data_ID:ID_rs_base_EX;
    //                     //(EX_calr||EX_cali||EX_lw||EX_sw)&&((WB_calr&&ID_instr_EX[`rs]==MEM_instr_WB[`rd])||(WB_cali&&ID_instr_EX[`rs]==MEM_instr_WB[`rt])||(WB_jal&&ID_instr_EX[`rs]==5'd31))?EX_data_WB://从W级（MEM/WB）alu_data转发
    //                     //(EX_calr||EX_cali||EX_lw||EX_sw)&&(WB_lw&&ID_instr_EX[`rs]==MEM_instr_WB[`rt])?MEM_data_WB:ID_rs_base_EX;//从W级（MEM/WB）dm_data转发
    // assign EX_rt_use=(ID_instr_EX[`rt]==5'd0)?ID_rt_EX:
    //             EX_calr&&((MEM_calr&&ID_instr_EX[`rt]==EX_instr_MEM[`rd])||(MEM_cali&&ID_instr_EX[`rt]==EX_instr_MEM[`rt])||(MEM_jal&&ID_instr_EX[`rt]==5'd31))?EX_out://从M级（EX/MEM）转发
    //             EX_calr&&((WB_calr&&ID_instr_EX[`rt]==MEM_instr_WB[`rd])||(WB_cali&&ID_instr_EX[`rt]==MEM_instr_WB[`rt])||(WB_jal&&ID_instr_EX[`rt]==5'd31))?EX_data_WB://从W级（MEM/WB）alu_data转发
    //             EX_calr&&(WB_lw&&ID_instr_EX[`rt]==MEM_instr_WB[`rt])?MEM_data_WB:ID_rt_EX;//ID_rt_EX;//从W级（MEM/WB）dm_data转发
    // assign MEM_data=//(EX_instr_MEM[`rt]==5'd0)?EX_rt_MEM:
    //                 MEM_sw&&((WB_calr&&EX_instr_MEM[`rt]==MEM_instr_WB[`rd])||(WB_cali&&EX_instr_MEM[`rt]==MEM_instr_WB[`rt])||(WB_jal&&EX_instr_MEM[`rt]==5'd31))?EX_data_WB://从W级（MEM/WB）alu_data转发
    //                 MEM_sw&&(WB_lw&&EX_instr_MEM[`rt]==MEM_instr_WB[`rt])?MEM_data_WB:EX_rt_MEM;//从W级（MEM/WB）dm_data转发
    // assign ID_rs_sign=(IF_instr_ID[`rs]==5'd0)?0:
    //                     (ID_jr||ID_beq)&&((MEM_calr&&IF_instr_ID[`rs]==EX_instr_MEM[`rd])||(MEM_cali&&IF_instr_ID[`rs]==EX_instr_MEM[`rt])||(MEM_jal&&IF_instr_ID[`rs]==5'd31))?1:0;//从M级（EX/MEM）转发
    //                     //(ID_jr||ID_beq)&&((WB_calr&&IF_instr_ID[`rs]==MEM_instr_WB[`rd])||(WB_cali&&IF_instr_ID[`rs]==MEM_instr_WB[`rt])||(WB_jal&&IF_instr_ID[`rs]==5'd31))?2://从W级（MEM/WB）alu_data转发
    //                     //(ID_jr||ID_beq)&&(WB_lw&&IF_instr_ID[`rs]==MEM_instr_WB[`rt])?3:0;//从W级（MEM/WB）dm_data转发
    // assign ID_rs_data=(ID_rs_sign==1)?EX_out:
    //                    (ID_rs_sign==2)?EX_data_WB:
    //                    (ID_rs_sign==3)?MEM_data_WB:0;
    // assign ID_rt_sign=(IF_instr_ID[`rt]==5'd0)?0:
    //                     ID_beq&&((MEM_calr&&IF_instr_ID[`rt]==EX_instr_MEM[`rd])||(MEM_cali&&IF_instr_ID[`rt]==EX_instr_MEM[`rt])||(MEM_jal&&IF_instr_ID[`rt]==5'd31))?1:0;//从M级（EX/MEM）转发
    //                     //ID_beq&&((WB_calr&&IF_instr_ID[`rt]==MEM_instr_WB[`rd])||(WB_cali&&IF_instr_ID[`rt]==MEM_instr_WB[`rt])||(WB_jal&&IF_instr_ID[`rt]==5'd31))?2://从W级（MEM/WB）alu_data转发
    //                     //ID_beq&&(WB_lw&&IF_instr_ID[`rt]==MEM_instr_WB[`rt])?3:0;//从W级（MEM/WB）dm_data转发
    // assign ID_rt_data=(ID_rt_sign==1)?EX_out:
    //                    (ID_rt_sign==2)?EX_data_WB:
    //                    (ID_rt_sign==3)?MEM_data_WB:0;


//     integer fp;
// initial begin
	
// fp = $fopen("info.txt","w");
// end