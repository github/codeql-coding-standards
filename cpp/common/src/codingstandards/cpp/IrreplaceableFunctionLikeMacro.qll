import cpp
import codingstandards.cpp.Macro
import codingstandards.cpp.Naming

/**
 * Macros that cannot be replaced by functions
 */
abstract class IrreplaceableFunctionLikeMacro extends FunctionLikeMacro { }

/** A function like macro that contains the use of a stringize or tokenize operator should not be replaced by a function. */
private class StringizeOrTokenizeMacro extends IrreplaceableFunctionLikeMacro {
  StringizeOrTokenizeMacro() {
    exists(TokenPastingOperator t | t.getMacro() = this) or
    exists(StringizingOperator s | s.getMacro() = this)
  }
}

/** A standard library function like macro that should not be replaced by a function. */
private class StandardLibraryFunctionLikeMacro extends IrreplaceableFunctionLikeMacro {
  StandardLibraryFunctionLikeMacro() { Naming::Cpp14::hasStandardLibraryMacroName(this.getName()) }
}

/** A function like macro invocation as an `asm` argument cannot be replaced by a function. */
private class AsmArgumentInvoked extends IrreplaceableFunctionLikeMacro {
  AsmArgumentInvoked() {
    any(AsmStmt s).getLocation().subsumes(this.getAnInvocation().getLocation())
  }
}

/** A macro that is only invoked with constant arguments is more likely to be compile-time evaluated than a function call so do not suggest replacement. */
private class OnlyConstantArgsInvoked extends IrreplaceableFunctionLikeMacro {
  OnlyConstantArgsInvoked() {
    forex(MacroInvocation mi | mi = this.getAnInvocation() |
      //int/float literals
      mi.getUnexpandedArgument(_).regexpMatch("\\d+")
      or
      //char literal or string literal, which is a literal surrounded by single quotes or double quotes
      mi.getUnexpandedArgument(_).regexpMatch("('[^']*'|\"[^\"]*\")")
    )
  }
}

/** A function like macro invoked to initialize an object with static storage that cannot be replaced with a function call. */
private class UsedToStaticInitialize extends IrreplaceableFunctionLikeMacro {
  UsedToStaticInitialize() {
    any(StaticStorageDurationVariable v).getInitializer().getExpr() =
      this.getAnInvocation().getExpr()
  }
}

/** A function like macro that is called with an argument that is an operator that cannot be replaced with a function call. */
private class FunctionLikeMacroWithOperatorArgument extends IrreplaceableFunctionLikeMacro {
  FunctionLikeMacroWithOperatorArgument() {
    exists(MacroInvocation mi | mi.getMacro() = this |
      mi.getUnexpandedArgument(_) = any(Operation op).getOperator()
    )
  }
}

private class GenericMacro extends IrreplaceableFunctionLikeMacro {
  GenericMacro() { getBody().matches("%_Generic%") }
}
