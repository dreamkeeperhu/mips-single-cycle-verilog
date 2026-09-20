`include "def.vh"

// 顶层：只做连线和写事件日志，不写任何逻辑。
// 这条纪律要守住 —— P5 转流水线时顶层会被反复改，里面有逻辑会变成灾难。
module mips(
    input clk,
    input reset
);

    // ---- 取指 ----
    wire [31:0] pc, npc, instr;

    pc  u_pc (.clk(clk), .reset(reset), .npc(npc), .pc(pc));
    im  u_im (.addr(pc), .instr(instr));

    // ---- 指令字段 ----
    wire [5:0]  op    = instr[31:26];
    wire [4:0]  rs    = instr[25:21];
    wire [4:0]  rt    = instr[20:16];
    wire [4:0]  rd    = instr[15:11];
    wire [5:0]  funct = instr[5:0];
    wire [15:0] imm16 = instr[15:0];
    wire [25:0] imm26 = instr[25:0];

    // ---- 控制信号 ----
    wire [1:0] NPCop, A3sel;
    wire [2:0] WDsel;
    wire [2:0] ALUop;
    wire RegWrite, MemWrite, ALUSrc, EXTop, BranchNeg;

    ctrl u_ctrl(
        .op(op), .funct(funct),
        .NPCop(NPCop), .RegWrite(RegWrite), .A3sel(A3sel),
        .WDsel(WDsel), .MemWrite(MemWrite), .ALUSrc(ALUSrc),
        .EXTop(EXTop), .BranchNeg(BranchNeg), .ALUop(ALUop)
    );

    // ---- 寄存器堆 ----
    wire [31:0] rd1, rd2, wd;
    wire [4:0]  a3 = (A3sel == `A3_RD) ? rd :
                     (A3sel == `A3_31) ? 5'd31 : rt;

    grf u_grf(
        .clk(clk), .reset(reset), .we(RegWrite),
        .a1(rs), .a2(rt), .a3(a3), .wd(wd),
        .rd1(rd1), .rd2(rd2)
    );

    // ---- 扩展 + ALU ----
    wire [31:0] ext32;
    ext u_ext(.imm16(imm16), .EXTop(EXTop), .ext32(ext32));

    wire [31:0] alu_b = ALUSrc ? ext32 : rd2;
    wire [31:0] alu_out;
    wire        zero;

    alu u_alu(.a(rd1), .b(alu_b), .aluop(ALUop), .y(alu_out), .zero(zero));

    // ---- 数据存储器 ----
    wire [31:0] dm_out;
    dm u_dm(
        .clk(clk), .reset(reset), .we(MemWrite),
        .addr(alu_out), .wd(rd2), .rd(dm_out)
    );

    // ---- 写回 ----
    wire [31:0] pc4 = pc + 32'd4;
    assign wd = (WDsel == `WD_DM)  ? dm_out :
                (WDsel == `WD_PC4) ? pc4    : 
                (WDsel == `WD_RD1) ? rd1    :alu_out;

    // ---- 下一条 PC ----
    wire taken = zero ^ BranchNeg;      // beq: zero；bne: ~zero
    npc u_npc(
        .pc(pc), .imm16(imm16), .imm26(imm26), .rsval(rd1),
        .npcop(NPCop), .taken(taken), .npc(npc)
    );

    // ---- 写事件日志：格式跟评测机 / MARS 的 lg 输出一致 ----
    always @(posedge clk) begin
        if (!reset) begin
            if (RegWrite)      // 写 $0 也要记录：动作发生了，只是 GRF 不真的写进去
                $display("@%h: $%2d <= %h", pc, a3, wd);
            if (MemWrite)
                $display("@%h: *%h <= %h", pc, {alu_out[31:2], 2'b00}, rd2);
        end
    end

endmodule
