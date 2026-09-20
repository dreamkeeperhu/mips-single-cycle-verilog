# 2026-09-20 练习指令存档

这里放的是练习用的**自编指令**，不是 MIPS 指令集的一部分。
上机前从主工程移出来，理由见下。

| 指令 | 编码 | 语义 |
|---|---|---|
| `bezal` | R, funct=0x31 | rt==0 时跳到 rs |
| `rorv`  | R, funct=0x3d | GPR[rd] ← ROR(GPR[rt], GPR[rs][4:0]) |
| `apc`   | op=0x1e | GPR[rt] ← PC+4 + sign_ext(offset\|\|0²) |
| `dbnz`  | op=0x16 | GPR[rs]−−；非零则跳 |

**为什么移出去**：课上的自编指令也是从未分配的 opcode 里挑的，
0x1e / 0x16 / funct 0x3d 恰好是最可能被选中的空档。主工程里留着
这几条，撞上就是一个静默的译码冲突——两条 wire 同时为真，
控制信号互相打架，而编译器不会说一个字。

完整实现随时可以取回：`git checkout practice-0920`

`mars_ext/` 下三个 .java 是写 MARS 指令插件的**模板**，
要用就拷回上级 `mars_ext/` 再跑 `build.sh`。
