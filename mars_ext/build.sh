#!/bin/bash
# 编译 mars_ext 下所有自编指令插件
set -e
cd "$(dirname "$0")"
MARS=${MARS_JAR:-/Users/hu/Desktop/CO/CO/repos/tools/COT/util/mars.jar}
javac -cp "$MARS" *.java
echo "已编译：$(ls *.class | tr '\n' ' ')"
