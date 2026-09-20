#!/bin/bash
# 用法：./run.sh prog.asm
# MARS 跑出黄金日志 → 汇编成 code.hex → iverilog 跑你的 CPU → diff
#
# mars_ext/*.class 会被自动挂上（BUAA 版 MARS 的 cl 选项），
# 所以课程组自编指令也能对拍 —— 新增一条就在 mars_ext/ 里写个同名类，
# 跑一次 ./mars_ext/build.sh 编译即可。
set -e
cd "$(dirname "$0")"
MARS=${MARS_JAR:-/Users/hu/Desktop/CO/CO/repos/tools/COT/util/mars.jar}
ASM=${1:?用法: ./run.sh prog.asm}

# 把自编指令插件拼成 "cl A.class cl B.class ..."
CL=()
for c in mars_ext/*.class; do
    [ -e "$c" ] && CL+=(cl "$c")
done

java -jar "$MARS" "${CL[@]}" nc lg mc CompactDataAtZero 2000 "$ASM" | grep '^@' > golden.txt
rm -f code.hex
java -jar "$MARS" "${CL[@]}" a mc CompactDataAtZero dump .text HexText code.hex "$ASM" > /dev/null

iverilog -o sim -I . *.v
vvp sim | grep '^@' > mine.txt || true

echo "黄金 $(wc -l < golden.txt) 行 / 你的 $(wc -l < mine.txt) 行"
if diff -q golden.txt mine.txt > /dev/null; then
    echo "完全一致 ✅"
else
    echo
    echo "第一处不一致（< 是 MARS，> 是你的）："
    diff golden.txt mine.txt | head -8
fi
