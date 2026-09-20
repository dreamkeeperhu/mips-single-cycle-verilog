// 自编指令 rorv：给 BUAA 版 MARS 用的插件，让课程组自编指令也能对拍。
//
//   rorv rd, rs, rt      GPR[rd] <- ROR(GPR[rt], GPR[rs][4:0])
//
// 编译： javac -cp <mars.jar> Rorv.java
// 使用： java -jar <mars.jar> cl Rorv.class nc lg mc CompactDataAtZero 2000 x.asm
//
// 掩码里 f/s/t 分别代表模板里的第 1/2/3 个操作数，跟它落在哪个字段无关：
//   f -> operands[0] = rd，放在 [15:11]
//   s -> operands[1] = rs，放在 [25:21]
//   t -> operands[2] = rt，放在 [20:16]
import mars.ProgramStatement;
import mars.ProcessingException;
import mars.mips.hardware.RegisterFile;
import mars.mips.instructions.InstructionLoad;

public class Rorv implements InstructionLoad {

    public String getTemplate() {
        return "rorv $t1,$t2,$t3";
    }

    public String getDescription() {
        return "Rotate right variable : set $t1 to $t3 rotated right by low 5 bits of $t2";
    }

    public String getFormatStr() {
        return "R";
    }

    public String getEncoding() {
        return "000000 sssss ttttt fffff 00000 111101";
    }

    public void simulate(ProgramStatement statement) throws ProcessingException {
        int[] op = statement.getOperands();
        int n = RegisterFile.getValue(op[1]) & 0x1f;
        int x = RegisterFile.getValue(op[2]);
        RegisterFile.updateRegister(op[0], Integer.rotateRight(x, n));
    }
}
