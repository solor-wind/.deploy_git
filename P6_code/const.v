//指令编码
`define func 5:0
`define opcode 31:26
`define rs 25:21
`define base 25:21
`define rt 20:16
`define rd 15:11
`define imm 15:0
`define offset 15:0
`define index 25:0


// add, sub, and, or, slt, sltu, lui
// addi, andi, ori
// lb, lh, lw, sb, sh, sw
// mult, multu, div, divu, mfhi, mflo, mthi, mtlo
// beq, bne, jal, jr


//R型指令（opcode=0）//use rt,rs=1//new rd=1
`define add 6'b100000
`define sub 6'b100010
`define and 6'b100100
`define or 6'b100101
`define slt 6'b101010
`define sltu 6'b101011
//乘除相关//use rt,rs=1
`define mult 6'b011000
`define multu 6'b011001
`define div 6'b011010
`define divu 6'b011011

`define mfhi 6'b010000//use=1，和busy特判//new rd=1
`define mflo 6'b010010//提示错误
`define mthi 6'b010001//提示错误//use rs=1//new 特判
`define mtlo 6'b010011
//跳转//use rs=0
`define jr 6'b001000

//立即数指令//use rs=1//new rt=1
`define lui 6'b001111//无use
`define ori 6'b001101
`define andi 6'b001100//提示错误
`define addi 6'b001000

//lw、sw相关//use rs=1
//new rt=2
`define lw 6'b100011
`define lh 6'b100001
`define lb 6'b100000
//use rt=2
`define sw 6'b101011
`define sh 6'b101001
`define sb 6'b101000

//分支//use rs,rt=0
`define beq 6'b000100
`define bne 6'b000101

//跳转//new 31=1
`define jal 6'b000011
