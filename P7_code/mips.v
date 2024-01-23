`include "const.v"
module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据
    output [31:0] w_inst_addr     // W 级 PC

);
    wire int_time0;
    wire int_time1;

    wire [31:0] cpu_instr_bridge;
    wire [31:0] cpu_addr_bridge;
    wire [31:0] cpu_WD_bridge;
    wire [31:0] cpu_RD_bridge;

    wire [31:0] WD;
    wire bridge_we_timer0;
    wire [31:0] timer0_RD_bridge;
    wire bridge_we_timer1;
    wire [31:0] timer1_RD_bridge;
    
    assign m_data_wdata=WD;
    assign m_data_addr=cpu_addr_bridge;
    assign m_int_addr=cpu_addr_bridge;//两个一样?


    CPU cpu(
        .clk(clk),
        .reset(reset),
        .int_expot(interrupt),
        .int_time0(int_time0),
        .int_time1(int_time1),
        .macroscopic_pc(macroscopic_pc),
        .i_inst_rdata(i_inst_rdata),
        .i_inst_addr(i_inst_addr),
        .w_grf_we(w_grf_we),
        .w_grf_addr(w_grf_addr),
        .w_grf_wdata(w_grf_wdata),
        .w_inst_addr(w_inst_addr),

        .m_inst_addr(m_inst_addr),
        .out_instr(cpu_instr_bridge),
        .out_addr(cpu_addr_bridge),
        .out_WD(cpu_WD_bridge),
        .out_RD(cpu_RD_bridge)
    );

    Bridge bridge(
        .MEM_instr(cpu_instr_bridge),
        .MEM_addr(cpu_addr_bridge),
        .MEM_WD(cpu_WD_bridge),
        .MEM_RD(cpu_RD_bridge),

        .WD(WD),

        .DM_RD(m_data_rdata),
        .m_data_byteen(m_data_byteen),

        .m_int_byteen(m_int_byteen),

        .Timer0_RD(timer0_RD_bridge),
        .Timer0_we(bridge_we_timer0),

        .Timer1_RD(timer1_RD_bridge),
        .Timer1_we(bridge_we_timer1)
    );

    TC Timer0(
        .clk(clk),
        .reset(reset),
        .Addr(cpu_addr_bridge[31:2]),
        .WE(bridge_we_timer0),
        .Din(WD),
        .Dout(timer0_RD_bridge),
        .IRQ(int_time0)
    );

    TC Timer1(
        .clk(clk),
        .reset(reset),
        .Addr(cpu_addr_bridge[31:2]),
        .WE(bridge_we_timer1),
        .Din(WD),
        .Dout(timer1_RD_bridge),
        .IRQ(int_time1)
    );
endmodule