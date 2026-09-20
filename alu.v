`include "def.vh"

// ALU：纯组合。注意它现在只认"功能"，不认"哪条指令"——
// 这就是 P3 里 type 只剩两格的那个问题的解法。
//
//   ALU_ADD  y = a + b
//   ALU_SUB  y = a - b
//   ALU_XOR  y = a ^ b
//   ALU_LUI  y = b << 16
//
// zero：y == 0。beq/bne 靠它判断 rs 和 rt 是否相等
//       （因为 rs-rt==0 等价于 rs==rt）。
module alu (
    input      [31:0] a,
    input      [31:0] b,
    input      [ 3:0] aluop,
    output reg [31:0] y,
    output            zero
);
    assign zero = (y == 0) ? 1 : 0;
    always @(*) begin
        case (aluop)
            `ALU_SUB: y = a - b;
            `ALU_LUI: y = b << 16;
            `ALU_XOR: y = a ^ b;
            `ALU_OR:  y = a | b;
            `ALU_B:   y = b;
            default:  y = a + b;
        endcase
    end

    // TODO: always @(*) case (aluop) ... default: 一定要写，否则会推出锁存器

    // TODO: assign zero = ...

endmodule
