# 基线存档 · 14 条指令的单周期 Verilog CPU

存档时间：2026-09-19
状态：**三个测试全部通过，可信**

```
smoke.asm   14 行   基础通路 + 分支 + 跳转
mem.asm      6 行   非 0 地址访存（专门防 dm 读写地址不一致）
hard.asm    32 行   边界值、溢出环绕、$0 保护、负偏移、往回跳、两层嵌套调用
```

## 指令集（14 条）

```
addu  subu                      R 型运算
addiu xori  ori   lui           I 型运算
lw    sw                        访存
beq   bne                       分支
j     jal   jr    jalr          跳转
nop                             免费获得（op=0 funct=0 不匹配任何指令 → 全部控制信号为 0）
```

## 架构要点（这是这份存档真正的价值）

**ALUop 独立于指令编号。** Controller 把 14 条指令译成 5 种运算
（`ADD / SUB / XOR / LUI / OR`），ALU 只认运算不认指令。

所以加一条新的运算类指令是：

```
def.vh    加一个 `ALU_xxx
ctrl.v    加一行 wire、或进 calc_r 或 calc_i、ALUop 加一路
alu.v     加一行运算
```

**已有指令一行都不用动，也没有数量上限**——对比 Logisim 那版用 4 位 type
当索引、只剩两格的窘境。

## 怎么用

```sh
# 从存档恢复（会覆盖工作目录里的同名文件）
cd ~/Desktop/CO/verilog/09192026
cp _baseline_14instr/*.v _baseline_14instr/*.vh _baseline_14instr/*.asm _baseline_14instr/run.sh .

# 存档目录本身也能独立跑
cd _baseline_14instr && ./run.sh hard.asm
```

加新指令前先跑一遍 `hard.asm`，加完再跑一遍——**新加的 MUX 分支很容易把原有指令的
默认选择改坏**，这是历年 P3 课上最常见的翻车方式。

目录名以 `_` 开头，不会被站点的题面发布脚本扫到。
