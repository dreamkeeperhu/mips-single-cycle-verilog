// 全工程共享的编码常量。新增指令时先改这里。
//
// ---- 命名两条规矩 ----
//   1. 档位常量按「它是什么」命名，不按「谁用它」命名。
//      WD_SLL 那种按指令命名的档，加一条 srl 就得再加一档，
//      档位数跟指令数挂钩 —— 这正是 P3 里 type 用完的那个病。
//   2. 所有控制信号一律 4 位，哪怕现在只有两档。位宽不统一 = 静默截断。
//
// ---- 跟课程材料/学长代码的名字对照 ----
//   本工程       通用叫法        管的是什么
//   A3sel        RegDst          GRF 的写地址口接哪个字段
//   WDsel        MemtoReg        GRF 的写数据口接哪一路
//   ALUBsel      ALUSrc          ALU 的 b 口接哪一路
//   NPCop        NPCOp / PCSrc   下一条 PC 从哪来

`ifndef DEF_VH
`define DEF_VH

// ---- NPCop：下一条 PC 从哪来 ----
`define NPC_PC4    4'd0   // PC + 4
`define NPC_J      4'd1   // {PC[31:28], imm26, 2'b00}
`define NPC_JR     4'd2   // 寄存器值
`define NPC_BR     4'd3   // taken ? PC+4+offset<<2 : PC+4
`define NPC_JR_T   4'd4   // taken ? 寄存器值 : PC+4

// ---- CMPop：cmp 判什么条件（跟指令编号无关，同 ALUop 的思路）----
// 一根 taken 同时供 npc（跳不跳）和顶层（条件写写不写）使用。
// 名字带 A_/B_ 的只看单个操作数，不带的比较两个 —— 光看名字就知道用了谁。
`define CMP_NONE   4'd0   // 恒为假
`define CMP_EQ     4'd1   // a == b
`define CMP_NE     4'd2   // a != b
`define CMP_B_Z    4'd3   // b == 0
`define CMP_B_NZ   4'd4   // b != 0
`define CMP_A_GEZ  4'd5   // signed(a) >= 0

// ---- A3sel：写哪个寄存器 ----
`define A3_RT      4'd0   // instr[20:16]
`define A3_RD      4'd1   // instr[15:11]
`define A3_31      4'd2   // $31

// ---- WDsel：写回 GRF 的值从哪来 ----
`define WD_ALU     4'd0
`define WD_DM      4'd1
`define WD_PC4     4'd2
`define WD_RD1     4'd3
`define WD_ROR     4'd4

// ---- ALUAsel / ALUBsel：ALU 两个输入口各接哪一路 ----
// 两个口各有自己的选择器。只给 b 口留选择（老的 ALUSrc）撑不住 sll 这类
// 需要把 sa 送进运算的指令。
`define ALUA_RD1   4'd0
`define ALUA_SA    4'd1   // 移位量，零扩展到 32 位
`define ALUB_RD2   4'd0
`define ALUB_EXT   4'd1   // 扩展后的立即数

// ---- ALUop：ALU 干什么（跟指令编号无关，这是 P3 的教训）----
`define ALU_ADD    4'd0
`define ALU_SUB    4'd1
`define ALU_XOR    4'd2
`define ALU_LUI    4'd3   // b << 16
`define ALU_OR     4'd4
`define ALU_SLL    4'd5   // b << a[4:0]
// 4'd6 ~ 4'd15 留给以后的 and / slt / srl / sra

// ---- EXTop：16 位立即数怎么补到 32 位 ----
`define EXT_ZERO   4'd0
`define EXT_SIGN   4'd1

`endif
