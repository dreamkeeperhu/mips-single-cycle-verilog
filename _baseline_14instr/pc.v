// PC：唯一的状态寄存器。同步、高有效复位到 0x3000。
//
// 契约：上升沿采样 npc；复位优先于更新。
module pc (
    input             clk,
    input             reset,
    input      [31:0] npc,
    output reg [31:0] pc
);

    // TODO: always @(posedge clk) —— reset 时置 0x3000，否则 pc <= npc
    always @(posedge clk) begin
        if (reset) begin
            pc <= 32'h00003000;
        end else begin
            pc <= npc;
        end
    end
endmodule
