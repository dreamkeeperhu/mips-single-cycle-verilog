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

    // 撞到全 0 的指令就收工（ROM 空的地方天然是 0）
    always @(negedge clk)
        if (!reset && u_mips.instr === 32'h0) $finish;
endmodule
