// 全工程共享的编码常量。新增指令时先改这里。
// ---- 跟课程材料/学长代码的名字对照 ----
//   本工程            通用叫法          管的是什么
//   A3sel             RegDst            GRF 的写地址口接哪个字段
//   WDsel             MemtoReg          GRF 的写数据口接哪一路
//   ALUSrc            ALUSrc            ALU 的 b 口接寄存器还是立即数
//   NPCop             NPCOp / PCSrc     下一条 PC 从哪来
// MemtoReg 这名字来自最早只有"ALU / 内存"两档的教科书 CPU，
// 现在有四档了（还多出 PC+4 和 RD1），名字早就不准，所以这里叫 WDsel。

`ifndef DEF_VH
`define DEF_VH

// ---- NPCop：下一条 PC 从哪来 ----
`define NPC_PC4    3'd0   // PC + 4
`define NPC_J      3'd1   // {PC[31:28], imm26, 2'b00}
`define NPC_JR     3'd2   // 寄存器值
`define NPC_BR     3'd3   // 分支：taken ? PC+4+offset<<2 : PC+4
`define NPC_BEZAL  3'd4

// ---- A3sel：写哪个寄存器 ----
`define A3_RT      2'd0   // instr[20:16]
`define A3_RD      2'd1   // instr[15:11]
`define A3_31      2'd2   // 31

// ---- WDsel：写什么值 ----
`define WD_ALU     3'd0
`define WD_DM      3'd1
`define WD_PC4     3'd2
`define WD_RD1     3'd3

// ---- ALUop：ALU 干什么（跟指令编号无关，这是 P3 的教训）----
`define ALU_ADD    3'd0
`define ALU_SUB    3'd1
`define ALU_XOR    3'd2
`define ALU_LUI    3'd3   // B << 16
`define ALU_OR     3'd4
`define ALU_B      3'd5
// 3'd4 ~ 3'd7 留给以后的 and/or/slt/移位

`endif
