// 自编指令 dbnz：dbnz rs, offset
//   GPR[rs] <- GPR[rs] - 1
//   if GPR[rs] - 1 != 0 then PC <- PC + 4 + sign_ext(offset || 0^2)
//
// 注意：COT/util/mars.jar 是 2022 年的分支，里面没有 BranchOperation
// （2025 那份 Mars_modified.jar 才有）。所以这里直接操作 PC：
// simulate 执行时 getProgramCounter() 已经指向下一条，即 PC+4，
// 加上 offset<<2 就是分支目标。等价于 BranchOperation.processBranch。
import mars.ProgramStatement;
import mars.ProcessingException;
import mars.mips.hardware.RegisterFile;
import mars.mips.instructions.InstructionLoad;

public class Dbnz implements InstructionLoad {
    public String getTemplate()    { return "dbnz $t1,label"; }
    public String getDescription() { return "Decrement and branch if not zero"; }
    public String getFormatStr()   { return "B"; }
    public String getEncoding()    { return "010110 fffff 00000 ssssssssssssssss"; }

    public void simulate(ProgramStatement s) throws ProcessingException {
        int[] op = s.getOperands();
        int v = RegisterFile.getValue(op[0]) - 1;
        RegisterFile.updateRegister(op[0], v);
        if (v != 0) {
            RegisterFile.setProgramCounter(RegisterFile.getProgramCounter() + (op[1] << 2));
        }
    }
}
