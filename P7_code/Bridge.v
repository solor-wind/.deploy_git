`include "const.v"
module Bridge(
    input [31:0] MEM_instr,
    input [31:0] MEM_addr,//从M获取地址
    input [31:0] MEM_WD,//M级给出的要写入的数据
    output [31:0] MEM_RD,//从外设读入的数据

    output [31:0] WD,//写入外设的数据

    input [31:0] DM_RD,//DM读出的数据
    output [3:0] m_data_byteen,//DM
    
    output[3:0] m_int_byteen,//外部中断写使能
    
    input [31:0] Timer0_RD,//Timer0读出的数据
    output Timer0_we,//Timer0写使能

    input [31:0] Timer1_RD,//Timer1读出的数据
    output Timer1_we//Timer1写使能
);
    assign MEM_RD=(MEM_addr>=0&&MEM_addr<=32'h2fff)?DM_RD:
                    (MEM_addr>=32'h7f00&&MEM_addr<=32'h7f0b)?Timer0_RD:
                    (MEM_addr>=32'h7f10&&MEM_addr<=32'h7f1b)?Timer1_RD:0;//要改吗?
    assign WD=(m_data_byteen==4'b1111)?MEM_WD:
                (m_data_byteen==4'b1100||m_data_byteen==4'b0011)?{MEM_WD[15:0],MEM_WD[15:0]}:
                (|m_data_byteen)?{MEM_WD[7:0],MEM_WD[7:0],MEM_WD[7:0],MEM_WD[7:0]}:MEM_WD;
    assign m_data_byteen=(!(MEM_addr>=0&&MEM_addr<=32'h2fff))?4'b0000:
                            (MEM_instr[`opcode]==`sw)?4'b1111:
                            (MEM_instr[`opcode]==`sh&&MEM_addr[1])?4'b1100:
                            (MEM_instr[`opcode]==`sh&&!MEM_addr[1])?4'b0011:
                            (MEM_instr[`opcode]==`sb&&MEM_addr[1:0]==2'b00)?4'b0001:
                            (MEM_instr[`opcode]==`sb&&MEM_addr[1:0]==2'b01)?4'b0010:
                            (MEM_instr[`opcode]==`sb&&MEM_addr[1:0]==2'b10)?4'b0100:
                            (MEM_instr[`opcode]==`sb&&MEM_addr[1:0]==2'b11)?4'b1000:4'b0000;

    wire we;
    assign we=(MEM_instr[`opcode]==`sw||MEM_instr[`opcode]==`sh||MEM_instr[`opcode]==`sb);
    assign m_int_byteen=(we&&MEM_addr>=32'h7f20&&MEM_addr<=32'h7f23)?4'b1111:4'b0000;
    assign Timer0_we=we&&MEM_addr>=32'h7f00&&MEM_addr<=32'h7f0b;
    assign Timer1_we=we&&MEM_addr>=32'h7f10&&MEM_addr<=32'h7f1b;


    // always@(*)begin
    //     m_data_byteen=4'b0000;
    //     m_int_byteen=4'b0000;
    //     Timer0_we=0;
    //     Timer1_we=0;
    //     case(MEM_addr[`opcode])
    //         `sw:m_data_byteen=4'b1111;
    //         `sh:m_data_byteen=(MEM_addr[1])?4'b1100:4'b0011;
    //         `sb:m_data_byteen=(MEM_addr[1:0]==2'b00)?4'b0001:
    //                             (MEM_addr[1:0]==2'b01)?4'b0010:
    //                             (MEM_addr[1:0]==2'b10)?4'b0100:4'b1000;
    //         `int:m_int_byteen=4'b1111;//不知道啥条件
    //         `time0:Timer0_we=1;//不知道啥条件
    //         `time1:Timer1_we=1;//不知道啥条件
    //         default:;
    //     endcase
    // end
endmodule