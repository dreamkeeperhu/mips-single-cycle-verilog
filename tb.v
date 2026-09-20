`timescale 1ns/1ps

module tb;
    reg clk = 0;
    reg reset = 1;

    mips u_mips(.clk(clk), .reset(reset));

    always #5 clk = ~clk;

    initial begin
        #10 reset = 0;          // 放开复位，从 0x3000 开始跑
        #20000 $display("[超时] 跑了 2000 个周期还没停，多半是 PC 跑飞了");
        $finish;
    end

    // 撞到 ROM 空白区的填充字就收工（见 im.v：不能用全 0，那是 nop）
    always @(negedge clk)
        if (!reset && u_mips.instr === 32'hffffffff) $finish;
endmodule
