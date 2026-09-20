# 覆盖测试：边界值、$0 保护、负偏移、往回跳、嵌套调用
    lui   $t0, 0x7fff
    xori  $t0, $t0, 0xffff      # $t0 = 0x7fffffff  最大正数
    lui   $t1, 0x8000           # $t1 = 0x80000000  最小负数
    addiu $t2, $0, -1           # $t2 = 0xffffffff  符号扩展到全 1
    xori  $t3, $0, 0xffff       # $t3 = 0x0000ffff  零扩展，高位必须是 0

    addu  $t4, $t0, $t2         # 0x7fffffff + (-1) = 0x7ffffffe
    addu  $t5, $t0, $t0         # 溢出环绕 = 0xfffffffe（addu 不报异常）
    subu  $t6, $t1, $t0         # 0x80000000 - 0x7fffffff = 1
    subu  $t7, $0,  $t0         # 0 - 最大正数
    xori  $s0, $t0, 0xffff      # 只影响低 16 位

    xori  $0,  $0, 0x1234       # $0 保护：这条不该产生任何写
    addu  $0,  $t0, $t1         # 同上

    addiu $s1, $0, 64           # 基址
    sw    $t0, 0($s1)
    sw    $t1, 4($s1)
    sw    $t2, 8($s1)
    lw    $s2, 8($s1)           # 读回 $t2
    lw    $s3, -64($s1)         # 负偏移 → 地址 0

    addiu $s4, $0, 3            # 循环 3 次，测往回跳的分支
loop:
    addiu $s4, $s4, -1
    addiu $s5, $s5, 10
    bne   $s4, $0, loop
    beq   $s4, $0, next         # 相等，该跳
    addiu $s6, $0, 0xbad        # 不该执行
next:
    jal   outer                 # 两层嵌套调用
    j     done
outer:
    addiu $s7, $0, 0x11
    addu  $k0, $ra, $0          # 自己保存返回地址（没有栈）
    jal   inner
    addu  $ra, $k0, $0
    jr    $ra
inner:
    addiu $k1, $0, 0x22
    jr    $ra
done:
    addiu $gp, $0, 0x99
