// 寄存器堆：组合读、上升沿写。
//
// 契约：
//   - 读：rd1/rd2 随 a1/a2 组合变化，不等时钟
//   - 写：we=1 时在上升沿把 wd 写进 a3
//   - $0 恒为 0：写它要被忽略（不是"写进去再读出 0"，是根本不写）
//   - reset：同步清零全部 32 个
module grf (
    input         clk,
    input         reset,
    input         we,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    input  [31:0] wd,
    output [31:0] rd1,
    output [31:0] rd2
);

    reg [31:0] regs[0:31];
    integer i;
    assign rd1 = a1 == 0 ? 0 : regs[a1];
    assign rd2 = a2 == 0 ? 0 : regs[a2];
    // TODO: 组合读（assign），注意 a==0 时读 0
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 0;
            end
        end else if (we && a3) begin
            regs[a3] <= wd;
        end
    end
    // TODO: always @(posedge clk) —— reset 清零（用 for 循环），否则 we && a3!=0 时写入

endmodule
