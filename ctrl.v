`include "def.vh"
`default_nettype none

// 控制器：纯组合。只看 opcode / funct / rt 字段，看不到任何数据。
//
// 写法要点（跟你 Logisim 那版的区别）：
//   1. 先把每条指令译成一根 wire，一条一行；
//   2. 每个控制信号一条 assign，把需要它的指令 "或" 起来；
//   3. ALUop / CMPop 独立于指令编号，所以新增一条运算或分支指令
//      = 加一行 wire + 或进几个 assign，不占任何"编号"，没有上限。
//
// **加指令只改这个文件**；只有现有档位不够用时，才按三处法则动 def.vh
// 和收货模块（见 加指令.md）。
module ctrl (
    input [5:0] op,
    input [5:0] funct,
    input [4:0] rt,    // REGIMM（op=0x01）这类指令的次操作码就藏在 rt 字段

    // ---- 多路选择：一律 4 位 ----
    output [3:0] NPCop,    // 下一条 PC 从哪来
    output [3:0] CMPop,    // 给 cmp：这条指令要判什么条件
    output [3:0] A3sel,    // 写哪个寄存器
    output [3:0] WDsel,    // 写回的值从哪来
    output [3:0] ALUAsel,  // ALU 的 a 口接哪一路
    output [3:0] ALUBsel,  // ALU 的 b 口接哪一路
    output [3:0] ALUop,    // ALU 算什么
    output [3:0] EXTop,    // 立即数怎么扩展

    // ---- 使能：无条件的一对，条件的一对 ----
    output       RegWrite,
    output       MemWrite,
    output       CondRegWrite,  // 写不写寄存器，看 cmp 吐出的 taken
    output       CondMemWrite   // 写不写内存，  看 cmp 吐出的 taken
);

    // ---- 译码：一条指令一行 ----
    wire R = (op == 6'h00);

    wire addu  = R & (funct == 6'h21);
    wire subu  = R & (funct == 6'h23);
    wire jr    = R & (funct == 6'h08);
    wire jalr  = R & (funct == 6'h09);
    wire bezal = R & (funct == 6'h31);
    wire movn  = R & (funct == 6'h0b);
    wire sll   = R & (funct == 6'h00);
    wire rorv  = R & (funct == 6'h3d);

    wire addiu = (op == 6'h09);
    wire xori  = (op == 6'h0e);
    wire lui   = (op == 6'h0f);
    wire lw    = (op == 6'h23);
    wire sw    = (op == 6'h2b);
    wire beq   = (op == 6'h04);
    wire bne   = (op == 6'h05);
    wire j     = (op == 6'h02);
    wire jal   = (op == 6'h03);
    wire ori   = (op == 6'h0d);

    wire bgezal = (op == 6'h01) & (rt == 5'h11);

    // 分类：加新指令时优先往这几类里塞，控制信号就不用动
    wire calc_r = addu | subu;               // 读 rs/rt，写 rd
    wire calc_i = addiu | xori | lui | ori;  // 读 rs，写 rt，第二操作数是立即数
    wire branch = beq | bne;
    wire link   = jal | jalr;                // 要把 PC+4 写进寄存器
    wire useimm = calc_i | lw | sw;          // ALU 的 b 口接立即数
    wire signext = addiu | lw | sw;          // 立即数要符号扩展

    // ---- 使能 ----
    assign RegWrite     = calc_r | calc_i | lw | link | bezal | sll | rorv;
    assign MemWrite     = sw;
    assign CondRegWrite = movn | bgezal;
    assign CondMemWrite = 1'b0;   // 目前还没有指令走这条通道

    // ---- 多路选择 ----
    assign EXTop   = signext ? `EXT_SIGN : `EXT_ZERO;

    assign ALUAsel = sll    ? `ALUA_SA  : `ALUA_RD1;
    assign ALUBsel = useimm ? `ALUB_EXT : `ALUB_RD2;

    assign A3sel = (jal | bgezal)               ? `A3_31 :
                   (calc_r | jalr | movn | sll | rorv) ? `A3_RD : `A3_RT;

    assign WDsel = (link | bgezal) ? `WD_PC4 :
                   lw              ? `WD_DM  :
                   movn            ? `WD_RD1 :
                   rorv            ? `WD_ROR : `WD_ALU;

    // 条件抽走之后 bgezal 和 beq/bne 的目标算法完全一样，共用 NPC_BR，不再单占一档
    assign NPCop = (j | jal)         ? `NPC_J    :
                   (jr | jalr)       ? `NPC_JR   :
                   (branch | bgezal) ? `NPC_BR   :
                   bezal             ? `NPC_JR_T : `NPC_PC4;

    // 条件判断交给 cmp 之后，beq/bne/bezal 不再借 ALU 算 zero，ALU 只管算数
    assign CMPop = beq    ? `CMP_EQ    :
                   bne    ? `CMP_NE    :
                   bezal  ? `CMP_B_Z   :   // rt == 0
                   movn   ? `CMP_B_NZ  :   // rt != 0
                   bgezal ? `CMP_A_GEZ : `CMP_NONE;

    assign ALUop = subu ? `ALU_SUB :
                   xori ? `ALU_XOR :
                   lui  ? `ALU_LUI :
                   ori  ? `ALU_OR  :
                   sll  ? `ALU_SLL : `ALU_ADD;

endmodule
