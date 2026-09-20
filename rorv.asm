# rorv 对拍程序。rorv 是自编指令，靠 mars_ext/Rorv.class 让 MARS 认识它。
    xori $t0, $0, 4
    lui  $t1, 0x1234
    ori  $t1, $t1, 0x5678      # $t1 = 0x12345678
    rorv $t2, $t0, $t1         # 转 4 位  -> 0x81234567
    rorv $t3, $0,  $t1         # n = 0，原样  -> 0x12345678  ← 这是本题唯一的坑
    xori $t4, $0, 31
    rorv $t5, $t4, $t1         # 转 31 位 = 左转 1 位 -> 0x2468acf0
    xori $t6, $0, 1
    rorv $t7, $t6, $t1         # 转 1 位 -> 0x091a2b3c
    lui  $s0, 0x8000
    xori $s1, $0, 1
    rorv $s2, $s1, $s0         # 最高位转到最低位 -> 0x40000000
    xori $s3, $0, 36           # 只取低 5 位 = 4，跟上面第一条同结果
    rorv $s4, $s3, $t1         # -> 0x81234567
