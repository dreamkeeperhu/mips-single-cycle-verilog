`include "def.vh"

// 下一条指令地址。纯组合，没有状态。
//
//   NPC_PC4  pc + 4
//   NPC_J    {pc[31:28], imm26, 2'b00}          j / jal
//   NPC_JR   rsval                                  jr / jalr（rsval 接的是 RD1）
//   NPC_BR   taken ? pc+4+{{14{imm16[15]}},imm16,2'b00} : pc+4
//
// 分支偏移为什么要左移 2：指令永远 4 字节对齐，低 2 位必为 0，
// 存在指令里是浪费，所以约定存的是"第几条指令"，用的时候乘 4。
module npc (
    input      [31:0] pc,
    input      [15:0] imm16,
    input      [25:0] imm26,
    input      [31:0] rsval,
    input      [ 1:0] npcop,
    input             taken,
    output reg [31:0] npc
);

    // TODO: always @(*) case (npcop) ... default: npc = pc + 32'd4;
    always @(*) begin
        case (npcop)
            `NPC_J:  npc = {pc[31:28], imm26, 2'b00};
            `NPC_JR: npc = rsval;
            `NPC_BR: npc = (taken == 1) ? (pc + 4 + ({{14{imm16[15]}}, imm16, 2'b00})) : (pc + 4);
            default: npc = pc + 4;
        endcase
    end
endmodule
