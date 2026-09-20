// 数据存储器：组合读、上升沿写。跟 GRF 同一套时序契约。
//
// 注意 addr 是字节地址，但存储是按字组织的 —— 要用 addr[?:2] 索引。
// 教学工程约定 reset 时清零（真实存储器没有这个能力）。
module dm (
    input         clk,
    input         reset,
    input         we,
    input  [31:0] addr,
    input  [31:0] wd,
    output [31:0] rd
);

    reg [31:0] mem[0:1023];

    // TODO: 组合读
    assign rd = mem[addr[11:2]];
    integer i;
    // TODO: always @(posedge clk) —— reset 清零，否则 we 时写入
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1) begin
                mem[i] <= 0;
            end
        end else if (we) begin
            mem[addr[11:2]] <= wd;
        end
    end
endmodule
