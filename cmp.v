`include "def.vh"

// 比较器：纯组合。**所有"跳不跳 / 写不写"的条件都在这里判**，只吐出一根 taken。
//
// 为什么要独立成模块，而不是继续用 ALU 的 zero：
//   1. 扩展性：以前每加一条条件类指令，就要往 npc 多拉一根条件线
//      （bezal 拉了 taken，bgezal 又拉了 rd1Bge0）——这是 P3 里
//      「type 只剩两格」那个病换了个地方。现在加一条 = 这里加一路 case，
//      npc / grf 的端口一根都不用动。
//   2. P5 要求：流水线里分支在 D 级决定，而 ALU 在 E 级，那时结果还没出来。
//      比较和运算现在就分家，P5 直接把这个模块放进 D 级。
//
// 注意 taken 同时服务三件事：npc 用它决定跳不跳，顶层用它决定条件写寄存器、
// 条件写内存要不要写。这几件事在硬件上是同一个判断，没理由算多遍。
module cmp (
    input      [31:0] a,      // 接 RD1（rs 的值）
    input      [31:0] b,      // 接 RD2（rt 的值）
    input      [ 3:0] cmpop,
    output reg        taken
);

    always @(*) begin
        case (cmpop)
            `CMP_EQ:    taken = (a == b);
            `CMP_NE:    taken = (a != b);
            `CMP_B_NZ:  taken = (b != 32'd0);
            `CMP_A_GEZ: taken = ~a[31];      // 符号位为 0 即非负
            default:    taken = 1'b0;
        endcase
    end

endmodule
