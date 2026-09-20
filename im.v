// 指令存储器：只读，组合输出。这个模块没什么可学的，直接给你。
// 程序放在 code.hex，第 0 行对应 PC = 0x3000。
module im(
    input  [31:0] addr,
    output [31:0] instr
);
    integer i;
    reg [31:0] mem [0:1023];          // 1024 条指令够用了

    initial begin
        // 空白区填 0xffffffff：opcode 0x3f 不是任何合法指令，
        // 而全 0 不行 —— 那是 nop（= sll $0,$0,0），会把测试台提前掐断
        for (i = 0; i < 1024; i = i + 1) mem[i] = 32'hffffffff;
        $readmemh("code.hex", mem);
    end

    assign instr = mem[addr[11:2]];   // 0x3000 的 [11:2] 正好是 0
endmodule
