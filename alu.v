`include "def.vh"

// ALU：纯组合。注意它只认"功能"，不认"哪条指令"——
// 这就是 P3 里 type 只剩两格的那个问题的解法。
//
//   ALU_ADD  y = a + b
//   ALU_SUB  y = a - b
//   ALU_XOR  y = a ^ b
//   ALU_OR   y = a | b
//   ALU_LUI  y = b << 16
//   ALU_SLL  y = b << a[4:0]
//
// 这里没有 zero 输出：分支条件由 cmp 模块负责，ALU 只管算数。
// 移位也在这里做，不在顶层 —— 顶层只连线。
module alu (
    input      [31:0] a,
    input      [31:0] b,
    input      [ 3:0] aluop,
    output reg [31:0] y
);
    always @(*) begin
        case (aluop)
            `ALU_SUB:  y = a - b;
            `ALU_LUI:  y = b << 16;
            `ALU_XOR:  y = a ^ b;
            `ALU_OR:   y = a | b;
            `ALU_SLL:  y = b << a[4:0];
            `ALU_ROR:  y = (b >> a[4:0]) | (b << (32 - a[4:0]));
            `ALU_DEC1: y = a - 1;
            default:   y = a + b;
        endcase
    end

endmodule
