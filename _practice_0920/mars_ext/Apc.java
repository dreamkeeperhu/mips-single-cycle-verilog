import mars.ProgramStatement;
import mars.ProcessingException;
import mars.mips.hardware.RegisterFile;
import mars.mips.instructions.InstructionLoad;

public class Apc implements InstructionLoad {
    public String getTemplate()    { return "apc $t1,-100"; }
    public String getDescription() { return "Address from PC : set $t1 to PC+4 plus the sign-extended word offset"; }
    public String getFormatStr()   { return "I"; }
    public String getEncoding()    { return "011110 00000 fffff ssssssssssssssss"; }

    public void simulate(ProgramStatement s) throws ProcessingException {
        int[] op = s.getOperands();
        // simulate 执行时 PC 已经指向下一条，所以它就是 PC+4
        RegisterFile.updateRegister(op[0], RegisterFile.getProgramCounter() + (op[1] << 2));
    }
}
