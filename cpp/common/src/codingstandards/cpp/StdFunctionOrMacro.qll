/**
 * This module intends to reduce the difficulty of handling the pattern where implementations
 * implement a function as a macro: the class `StdFunctionOrMacro<...>::Call` matches both std
 * function calls as well as std function macro expansions.
 *
 * For instance, `atomic_init` may be implemented as a function, but is also implemented as
 * `#DEFINE atomic_init(x) __c11_atomic_init(x)` on some platforms. This module aids in finding
 * calls to any standard function which may be a macro, and has predefined behavior for
 * handling `__c11_*` macros.
 *
 * Since a macro can be defined to expand to any expression, we cannot know generally which
 * expanded expressions in `f(x, y)` correspond to arguments `x` or `y`. To handle this, the
 * following inference options are available:
 *  - `NoMacroExpansionInference`: Assume any expression in the macro expansion could correspond to
 *    any macro argument.
 *  - `C11FunctionWrapperMacro`: Check if the macro expands to a function call prefixed with
 *    `__c11_` and if so, return the corresponding argument. Otherwise, fall back to
 *    `NoMacroExpansionInference`.
 *  - `InferMacroExpansionArguments`: Implement your own logic for inferring the argument.
 *
 * To use this module, pick one of the above inference strategies, and then create a predicate for
 * the name you wish to match. For instance:
 *
 * ```codeql
 *   private string atomicInit() { result = "atomic_init" }
 *
 *   from StdFunctionOrMacro<C11FunctionWrapperMacro, atomicInit/0>::Call c
 *   select c.getArgument(0)
 * ```
 */

import cpp as cpp

/** Specify the name of your function as a predicate */
signature string getName();

/** Signature module to implement custom argument resolution behavior in expanded macros */
signature module InferMacroExpansionArguments {
  bindingset[mi, argumentIdx]
  cpp::Expr inferArgument(cpp::MacroInvocation mi, int argumentIdx);
}

/** Assume all subexpressions of an expanded macro may be the result of any ith argument */
module NoMacroExpansionInference implements InferMacroExpansionArguments {
  bindingset[mi, argumentIdx]
  cpp::Expr inferArgument(cpp::MacroInvocation mi, int argumentIdx) {
    result.getParent*() = mi.getExpr()
  }
}

/** Assume macro `f(x, y, ...)` expands to `__c11_f(x, y, ...)`. */
module C11FunctionWrapperMacro implements InferMacroExpansionArguments {
  bindingset[mi, argumentIdx]
  cpp::Expr inferArgument(cpp::MacroInvocation mi, int argumentIdx) {
    if mi.getExpr().(cpp::FunctionCall).getTarget().hasName("__c11_" + mi.getMacroName())
    then result = mi.getExpr().(cpp::FunctionCall).getArgument(argumentIdx)
    else result = NoMacroExpansionInference::inferArgument(mi, argumentIdx)
  }
}

/**
 * A module to find calls to standard functions, or expansions of macros with the same name.
 *
 * To use this module, specify a name predicate and an inference strategy for correlating macro
 * expansions to macro arguments.
 *
 * For example:
 *
 * ```codeql
 *   private string atomicInit() { result = "atomic_init" }
 *   from StdFunctionOrMacro<C11FunctionWrapperMacro, atomicInit/0>::Call c
 *   select c.getArgument(0)
 * ```
 */
module StdFunctionOrMacro<InferMacroExpansionArguments InferExpansion, getName/0 getStdName> {
  final private class Expr = cpp::Expr;

  final private class FunctionCall = cpp::FunctionCall;

  final private class MacroInvocation = cpp::MacroInvocation;

  private newtype TStdCall =
    TStdFunctionCall(FunctionCall fc) { fc.getTarget().hasName(getStdName()) } or
    TStdMacroInvocation(MacroInvocation mi) { mi.getMacro().hasName(getStdName()) }

  /**
   * A call to a standard function or an expansion of a macro with the same name.
   */
  class Call extends TStdCall {
    bindingset[this, argumentIdx]
    Expr getArgument(int argumentIdx) {
      exists(FunctionCall fc |
        this = TStdFunctionCall(fc) and
        result = fc.getArgument(argumentIdx)
      )
      or
      exists(MacroInvocation mi |
        this = TStdMacroInvocation(mi) and
        result = InferExpansion::inferArgument(mi, argumentIdx)
      )
    }

    string toString() {
      this = TStdFunctionCall(_) and
      result = "Standard function call"
      or
      this = TStdMacroInvocation(_) and
      result = "Invocation of a standard function implemented as a macro"
    }
  }
}
