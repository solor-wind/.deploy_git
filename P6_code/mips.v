`include "const.v"
module mips(
    input clk,
    input reset,

    input [31:0] i_inst_rdata,
    output [31:0] i_inst_addr,

    input [31:0] m_data_rdata,//读出存储的数据
    output [31:0] m_data_addr,//写/读的地址
    output [31:0] m_data_wdata,//写入的数据
    output [3:0] m_data_byteen,//字节使能
    output [31:0] m_inst_addr,//M级pc

    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr
);
    assign m_data_addr=EX_out;
    assign m_data_wdata=(m_data_byteen==4'b1111)?MEM_data:
                        (m_data_byteen==4'b1100||m_data_byteen==4'b0011)?{MEM_data[15:0],MEM_data[15:0]}:{MEM_data[7:0],MEM_data[7:0],MEM_data[7:0],MEM_data[7:0]};
    assign m_inst_addr=EX_pc_MEM;
    assign w_grf_we=WB_we_ID;
    assign w_grf_addr=WB_addr_ID;
    assign w_grf_wdata=WB_data_ID;
    assign w_inst_addr=WB_pc_ID;  

    wire stall;


    //转发相关
    wire [31:0] EX_rs_base;
    wire [31:0] EX_rt;
    wire [31:0] MEM_data;
    wire [2:0] ID_rs_sign;
    wire [31:0] ID_rs_data;
    wire [2:0] ID_rt_sign;
    wire [31:0] ID_rt_data;

    assign ID_rs_sign=(IF_instr_ID[`rs]==5'd0)?0:
                        (MEM_new&&IF_instr_ID[`rs]==MEM_new_addr)?1:0;//从M级（EX/MEM）转发
    assign ID_rs_data=(ID_rs_sign==1)?EX_out:0;
    assign ID_rt_sign=(IF_instr_ID[`rt]==5'd0)?0:
                        (MEM_new&&IF_instr_ID[`rt]==MEM_new_addr)?1:0;//从M级（EX/MEM）转发
    assign ID_rt_data=(ID_rt_sign==1)?EX_out:0;
    assign EX_rs_base=(ID_instr_EX[`rs]==5'd0)?ID_rs_base_EX:
                        (MEM_new&&ID_instr_EX[`rs]==MEM_new_addr)?EX_out://M级转发
                        (WB_we_ID&&ID_instr_EX[`rs]==WB_addr_ID)?WB_data_ID:ID_rs_base_EX;//W级转发    
    assign EX_rt=(ID_instr_EX[`rt]==5'd0)?ID_rt_EX:
                    (MEM_new&&ID_instr_EX[`rt]==MEM_new_addr)?EX_out://M级转发
                    (WB_we_ID&&ID_instr_EX[`rt]==WB_addr_ID)?WB_data_ID:ID_rt_EX;//W级转发
    assign MEM_data=(EX_instr_MEM[`rt]==5'd0)?EX_rt_MEM:
                    (WB_we_ID&&EX_instr_MEM[`rt]==WB_addr_ID)?WB_data_ID:EX_rt_MEM;//W级转发

    
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
    wire busy;

    wire MEM_new;
    wire [4:0] MEM_new_addr;
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
        .IF_instr_ID(IF_instr_ID),

        .IF_instr(i_inst_rdata),
        .IF_pc(i_inst_addr)
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
        .EX_rt(EX_rt),

        .EX_out(EX_out),
        .EX_rt_MEM(EX_rt_MEM),
        .EX_instr_MEM(EX_instr_MEM),
        .EX_pc_MEM(EX_pc_MEM),

        .busy(busy)
    );
    
    MEM memory(
        .clk(clk),
        .rst(reset),
        .MEM_pc(EX_pc_MEM),
        .MEM_instr(EX_instr_MEM),
        .MEM_addr(EX_out),
        .MEM_data(m_data_rdata),

        .MEM_new(MEM_new),
        .MEM_new_addr(MEM_new_addr),

        .MEM_data_WB(MEM_data_WB),
        .EX_data_WB(EX_data_WB),
        .MEM_instr_WB(MEM_instr_WB),
        .MEM_pc_WB(MEM_pc_WB),
        .m_data_byteen(m_data_byteen)
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
        .busy(busy),
        .stall(stall)
    );
endmodule


//     integer fp;
// initial begin
	
// fp = $fopen("info.txt","w");
// end