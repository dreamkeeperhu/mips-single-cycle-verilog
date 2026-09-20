# dbnz 对拍程序
      xori  $t0, $0, 3
      xori  $t1, $0, 0
loop: addiu $t1, $t1, 10
      dbnz  $t0, loop        # 3->2 跳, 2->1 跳, 1->0 不跳
      xori  $t2, $0, 1
      dbnz  $t2, L1          # 1->0，不跳
      xori  $t3, $0, 0x1111  # 应该执行
L1:   xori  $t4, $0, 0
      dbnz  $t4, L2          # 0->-1，非零，跳
      xori  $t5, $0, 0xdead  # 应该被跳过
L2:   xori  $t6, $0, 0x2222
