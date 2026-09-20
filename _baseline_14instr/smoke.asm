# 冒烟测试：只用你 CPU 支持的 13 条指令
# 注意用的是 xori 不是 ori —— 你的指令集里是 xori
    xori  $t0, $0, 5           # $8  = 5
    xori  $t1, $0, 5           # $9  = 5
    lui   $t2, 0x1234          # $10 = 0x12340000
    addiu $t3, $t0, -3         # $11 = 2        验符号扩展
    xori  $t4, $t0, 0xffff     # $12 = 0xfffa   验零扩展
    addu  $t5, $t0, $t1        # $13 = 10
    subu  $t6, $t1, $t0        # $14 = 0
    sw    $t0, 0($0)           # mem[0] = 5
    lw    $t7, 0($0)           # $15 = 5
    beq   $t0, $t1, L1         # 相等，应该跳
    xori  $s0, $0, 0xdead      # 跳过了就不该出现
L1: bne   $t0, $t1, L2         # 相等，不该跳
    xori  $s1, $0, 0x1111      # 应该执行
L2: jal   sub1                 # $31 = 返回地址
    xori  $s2, $0, 0x2222      # jr 回来后执行这条
    j     done
sub1:
    xori  $s3, $0, 0x3333
    jr    $ra
done:
    xori  $s4, $0, 0x4444
