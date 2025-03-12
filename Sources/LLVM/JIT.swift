#if SWIFT_PACKAGE
  import cllvm
#endif

public final class JIT {

  let jit = UnsafeMutablePointer<LLVMOrcLLJITRef?>(bitPattern: 0)
  let mainDyLib: LLVMOrcJITDylibRef

  public init() {
    LLVMInitializeNativeTarget()
    LLVMInitializeNativeAsmPrinter()

    LLVMOrcCreateLLJIT(self.jit, nil)
    self.mainDyLib = LLVMOrcLLJITGetMainJITDylib(jit!.pointee)
  }

  public func compile(module: Module, name: String) -> LLVMOrcExecutorAddress {
    let threadContext = LLVMOrcCreateNewThreadSafeContext()
    let threadModule = LLVMOrcCreateNewThreadSafeModule(module.llvm, threadContext)
    LLVMOrcLLJITAddLLVMIRModule(jit!.pointee, self.mainDyLib, threadModule)

    let res = UnsafeMutablePointer<LLVMOrcExecutorAddress>(bitPattern: 0)
    LLVMOrcLLJITLookup(jit!.pointee, res, name)

    return res!.pointee
  }

  deinit {
    LLVMOrcDisposeLLJIT(jit!.pointee)
    LLVMShutdown()
  }
}
