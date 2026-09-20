`include "def.vh"

// 扩展器：16 位立即数补到 32 位。纯组合。
//
//   EXT_SIGN  算地址、有符号加法（addiu / lw / sw）
//   EXT_ZERO  逻辑运算，高位不该被符号污染（xori / ori）
module ext (
    input      [15:0] imm16,
    input      [ 3:0] extop,
    output reg [31:0] ext32
);
    always @(*) begin
        case (extop)
            `EXT_SIGN: ext32 = {{16{imm16[15]}}, imm16};
            `EXT_SIGN_SH2: ext32 = {{14{imm16[15]}},imm16,2'b00};
            default:   ext32 = {16'b0, imm16};
        endcase
    end
endmodule
