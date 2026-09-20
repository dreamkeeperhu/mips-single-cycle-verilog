# bgezal 专项测试： bgezal rs, offset
#   GPR[31] <- PC+4                      ← 无条件，不跳也要写
#   if GPR[rs] >= 0 then PC <- PC+4+offset<<2
    xori  $t0, $0,  5          # $8  = 5            正
    xori  $t1, $0,  0          # $9  = 0            零，边界
    lui   $t2, 0xffff          # $10 = 0xffff0000   负（最高位 1）
    addiu $t3, $0,  -1         # $11 = 0xffffffff   负（全 1）

    bgezal $t0, L1             # 5 >= 0   → 跳
    xori  $s0, $0, 0x1111      # 被跳过，不该出现在日志里
L1: bgezal $t1, L2             # 0 >= 0   → 跳（边界：等于 0 也算非负）
    xori  $s1, $0, 0x2222      # 被跳过
L2: bgezal $t2, L3             # 负       → 不跳，但 $31 照样写
    xori  $s2, $0, 0x3333      # 应该执行
L3: bgezal $t3, L4             # 负       → 不跳
    xori  $s3, $0, 0x4444      # 应该执行
L4: bgezal $0,  L5             # $0 = 0   → 跳
    xori  $s4, $0, 0x5555      # 被跳过
L5: addu  $s5, $ra, $0         # 把最后一次的 $31 读出来对一下

    # 往回跳：$t4 从 1 递减，第一轮 0>=0 跳回，第二轮 -1<0 落下来
    addiu $t4, $0, 1
L6: addiu $t4, $t4, -1
    bgezal $t4, L6
    addu  $s6, $t4, $0         # $22 = -1，证明循环恰好走了两轮
