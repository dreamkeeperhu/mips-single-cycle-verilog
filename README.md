# MIPS 单周期 CPU（Verilog）

北航 计算机组成原理 P4 的单周期 CPU。iverilog 仿真，靠跟 MARS 对拍验证。

> **当前状态：工作目录正在加新指令，`ctrl.v` 第 60 / 64 行留着未填完的 `?` 占位符，
> 所以根目录这一版编译不过。** 已知可信的版本在 `_baseline_14instr/`
> （14 条指令，三个测试全过，`iverilog` 编译干净，`golden.txt == mine.txt`）。

## 目录

```
*.v  *.vh              工作目录（正在加 bezal / movn，未完成）
_baseline_14instr/     14 条指令的可信存档，可独立运行
run.sh                 一键对拍：MARS 出黄金日志 → 汇编 → iverilog → diff
smoke.asm mem.asm hard.asm   三个测试程序
```

## 模块划分

| 文件 | 职责 | 时序 |
|---|---|---|
| `pc.v` | 程序计数器，复位到 `0x3000` | 时序 |
| `im.v` | 指令 ROM，从 `code.hex` 载入 | 组合读 |
| `ctrl.v` | 控制器，**只看 op / funct，看不到任何数据** | 纯组合 |
| `grf.v` | 寄存器堆，组合读 / 上升沿写，`$0` 恒 0 | 混合 |
| `ext.v` | 立即数扩展（零 / 符号） | 纯组合 |
| `alu.v` | ALU，**只认运算不认指令** | 纯组合 |
| `dm.v` | 数据存储器 | 混合 |
| `npc.v` | 下一条 PC 的选择 | 纯组合 |
| `mips.v` | 顶层，**只连线 + 打写事件日志，不含逻辑** | — |

## 控制信号

`def.vh` 里是全部编码常量。加指令时先改这里。

| 信号 | 别处的叫法 | 管什么 |
|---|---|---|
| `RegWrite` | → `grf.we` | GRF 这一沿写不写 |
| `MemWrite` | → `dm.we` | DM 这一沿写不写 |
| `A3sel` | RegDst | 写哪个寄存器号（rt / rd / 31） |
| `WDsel` | MemtoReg | 写回值从哪来（ALU / DM / PC+4 / RD1） |
| `ALUSrc` | ALUSrc | ALU 的 b 口接 RD2 还是扩展后的立即数 |
| `EXTop` | — | 0 零扩展 / 1 符号扩展 |
| `ALUop` | ALUCtrl | ALU 做什么运算，**与指令编号解耦** |
| `NPCop` | NPCOp / PCSrc | 下一条 PC 从哪来 |
| `BranchNeg` | — | beq=0 / bne=1，跟 ALU 的 `zero` 异或得到 `taken` |

## 设计约定

1. **`ctrl` 拿不到数据通路上的值。** 数据相关的判断在顶层合成：
   分支是 `taken = zero ^ BranchNeg`，同理条件写回也应在顶层把
   `RegWrite` 与条件相与后再接到 `grf.we`。
2. **`ALUop` 独立于指令编号。** 加一条运算类指令 = `def.vh` 加常量 +
   `alu.v` 加一路 case + `ctrl.v` 加一行 wire，已有指令一行不动。
3. **顶层不写逻辑**，只做端口连接。P5 转流水线时顶层会被反复重写。

## 已实现指令（基线 14 条）

```
addu subu                 R 型运算
addiu xori ori lui        I 型运算
lw sw                     访存
beq bne                   分支
j jal jr jalr             跳转
nop                       免费（op=0 funct=0 不匹配任何指令 → 控制信号全 0）
```

工作目录里正在加的：`bezal`（自定义，R 型 funct=0x31）、`movn`。

## 怎么跑

需要 `iverilog` 和 MARS。

```sh
export MARS_JAR=/path/to/mars.jar
cd _baseline_14instr && ./run.sh hard.asm
```

`run.sh` 会用 MARS 跑出黄金写事件日志（`golden.txt`），把同一个 `.asm`
汇编成 `code.hex` 喂给 iverilog，再把仿真输出（`mine.txt`）跟黄金日志逐行 diff。
两个日志格式一致：`@<pc>: $<reg> <= <value>` 和 `@<pc>: *<addr> <= <value>`。
