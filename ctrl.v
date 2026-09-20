`include "def.vh"
`default_nettype none

// 控制器：纯组合。只看 opcode 和 funct，看不到任何数据。
//
// 写法要点（跟你 Logisim 那版的区别）：
//   1. 先把每条指令译成一根 wire，一条一行；
//   2. 每个控制信号一条 assign，把需要它的指令 "或" 起来；
//   3. ALUop 独立于指令，所以新增一条 R 型运算指令 = 加一行 wire + 或进几个 assign，
//      不占任何"编号"，没有上限。
module ctrl (
    input [5:0] op,
    input [5:0] funct,

    output [2:0] NPCop,
    output       RegWrite,
    output [1:0] A3sel,
    output [1:0] WDsel,
    output       MemWrite,
    output       ALUSrc,     // 0: RD2   1: 扩展后的立即数
    output       EXTop,      // 0: 零扩展 1: 符号扩展
    output       BranchNeg,  // beq=0, bne=1；跟 ALU 的 Zero 异或得到 taken
    output [2:0] ALUop
);

    // ---- 译码：一条指令一行 ----
    wire R = (op == 6'h00);

    wire addu = R & (funct == 6'h21);
    wire subu = R & (funct == 6'h23);
    wire jr = R & (funct == 6'h08);
    wire jalr = R & (funct == 6'h09);
    wire bezal = R & (funct == 6'h31);

    wire addiu = (op == 6'h09);
    wire xori = (op == 6'h0e);
    wire lui = (op == 6'h0f);
    wire lw = (op == 6'h23);
    wire sw = (op == 6'h2b);
    wire beq = (op == 6'h04);
    wire bne = (op == 6'h05);
    wire j = (op == 6'h02);
    wire jal = (op == 6'h03);
    wire ori = (op == 6'h0d);


    // 分类：加新指令时优先往这几类里塞，控制信号就不用动
    wire calc_r = addu | subu;  // 读 rs/rt，写 rd
    wire calc_i = addiu | xori | lui | ori;  // 读 rs，写 rt，第二操作数是立即数
    wire branch = beq | bne;
    wire link = jal | jalr;  // 要把 PC+4 写进寄存器

    // ---- 控制信号：一个信号一行 ----
    assign RegWrite = calc_r | calc_i | lw | link | bezal ;
    assign MemWrite = sw;
    assign ALUSrc = calc_i | lw | sw;
    assign EXTop = addiu | lw | sw;  // 只有这几条要符号扩展
    assign BranchNeg = bne;

    assign A3sel = jal ? `A3_31 : (calc_r | jalr) ? `A3_RD : ?  `A3_RT;

    assign WDsel = link ? `WD_PC4 : lw ? `WD_DM : `WD_ALU;

    assign NPCop = (j | jal) ? `NPC_J : (jr | jalr) ? `NPC_JR : branch ? `NPC_BR : ? bezal ? `NPC_BEZAL :  `NPC_PC4;

    assign ALUop     = (subu|branch) ? `ALU_SUB :
                       xori          ? `ALU_XOR :
                       lui           ? `ALU_LUI : 
                       ori           ? `ALU_OR  : 
                       bezal         ? `ALU_B   :`ALU_ADD;

endmodule
