// 指令存储器：只读，组合输出。这个模块没什么可学的，直接给你。
// 程序放在 code.hex，第 0 行对应 PC = 0x3000。
module im(
    input  [31:0] addr,
    output [31:0] instr
);
    integer i;
    reg [31:0] mem [0:1023];          // 1024 条指令够用了

    initial begin
        for (i = 0; i < 1024; i = i + 1) mem[i] = 32'b0;   // 先清零，
        $readmemh("code.hex", mem);                        // 程序之外才是全 0，
    end                                                    // testbench 靠它判断跑完了

    assign instr = mem[addr[11:2]];   // 0x3000 的 [11:2] 正好是 0
endmodule
