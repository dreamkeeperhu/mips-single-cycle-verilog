#!/bin/bash
# 用法：./run.sh prog.asm
# MARS 跑出黄金日志 → 汇编成 code.hex → iverilog 跑你的 CPU → diff
set -e
cd "$(dirname "$0")"
MARS=${MARS_JAR:-/Users/hu/Desktop/CO/CO/repos/tools/COT/util/mars.jar}
ASM=${1:?用法: ./run.sh prog.asm}

java -jar "$MARS" nc lg mc CompactDataAtZero 2000 "$ASM" | grep '^@' > golden.txt
rm -f code.hex
java -jar "$MARS" a mc CompactDataAtZero dump .text HexText code.hex "$ASM" > /dev/null

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
