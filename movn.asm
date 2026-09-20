# movn 专项测试： movn rd, rs, rt  →  if (GPR[rt] != 0) GPR[rd] = GPR[rs]
# 关键是"不写"的那几条：它们在 MARS 日志里根本不出现，
# 如果你的 CPU 多打一行或者少打一行，diff 立刻暴露。
    xori  $t0, $0,  0x1234     # $8  = 0x1234   要被搬运的值
    xori  $t1, $0,  0          # $9  = 0        条件为假
    xori  $t2, $0,  1          # $10 = 1        条件为真
    xori  $t3, $0,  0xffff     # $11 = 0xffff   条件为真（高位为 0 也算非零）
    lui   $t4, 0x8000          # $12 = 0x80000000  只有最高位是 1，验缩位或

    xori  $s0, $0,  0xaaaa     # $16 = 0xaaaa   哨兵，下面几条不该覆盖它
    xori  $s1, $0,  0xbbbb     # $17 = 0xbbbb   哨兵

    movn  $s0, $t0, $t1        # rt=0    → 不写，$16 应保持 0xaaaa
    movn  $s1, $t0, $t2        # rt=1    → 写，  $17 = 0x1234
    movn  $s2, $t0, $t3        # rt≠0    → 写，  $18 = 0x1234
    movn  $s3, $t0, $t4        # 只有最高位 → 写，$19 = 0x1234
    movn  $s4, $0,  $t2        # 搬 $0   → 写，  $20 = 0
    movn  $0,  $t0, $t2        # 写 $0   → 动作发生但 GRF 不变

    subu  $t5, $s0, $0         # $13 = $16，把哨兵读出来证明没被改
    subu  $t6, $s1, $0         # $14 = $17
