// 扩展器：16 位立即数补到 32 位。纯组合。
//
// EXTop = 1 符号扩展（addiu / lw / sw：算地址和有符号加法）
// EXTop = 0 零扩展  （xori：逻辑运算，高位不该被符号污染）
//
// 提示：符号扩展在 Verilog 里是 {{16{imm16[15]}}, imm16}
module ext(
    input  [15:0] imm16,
    input         EXTop,
    output [31:0] ext32
);
    assign ext32 = (EXTop == 0) ? ({{16'b0000000000000000},imm16}) : ({{16{imm16[15]}},imm16});
    // TODO

endmodule
