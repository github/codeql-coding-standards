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

private string underscoresPrefix() { result = "__" }

private string c11Prefix() { result = "__c11_" }

private string atomicInit() { result = "atomic_init" }

class AtomicInitCall = StdFunctionOrMacro<C11FunctionWrapperMacro, atomicInit/0>::Call;

private string readlink() { result = "readlink" }

class ReadlinkCall extends StdFunctionOrMacro<UnderscoredFunctionWrapperMacro, readlink/0>::Call {
  /** The first argument to readlink is the file path. */
  cpp::Expr getPathArg() { result = this.getArgument(0) }

  /** The second argument to readlink is the size of the buffer. */
  cpp::Expr getBufferArg() { result = this.getArgument(1) }

  /** The third argument to readlink is the size of the buffer. */
  cpp::Expr getSizeArg() { result = this.getArgument(2) }
}

/** Specify the name of your function as a predicate */
private signature string getName();

/** Signature module to implement custom argument resolution behavior in expanded macros */
private signature module InferMacroExpansionArguments {
  bindingset[mi, argumentIdx]
  cpp::Expr inferArgument(cpp::MacroInvocation mi, int argumentIdx);

  /** Get an expression representing the result of this function call if it is a macro */
  bindingset[mi]
  cpp::Expr inferExpr(cpp::MacroInvocation mi);
}

/** Assume macro `f(x, y, ...)` expands to `__c11_f(x, y, ...)`. */
private module C11FunctionWrapperMacro implements InferMacroExpansionArguments {
  import PrefixedFunctionWrapperMacro<c11Prefix/0>
}

/** Assume macro `f(x, y, ...)` expands to `__f(x, y, ...)`. */
private module UnderscoredFunctionWrapperMacro implements InferMacroExpansionArguments {
  import PrefixedFunctionWrapperMacro<underscoresPrefix/0>
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
private module StdFunctionOrMacro<InferMacroExpansionArguments InferExpansion, getName/0 getStdName>
{
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

    /**
     * Get the `Element` of this pseudo-call: either the FunctionCall or the MacroInvocation.
     */
    cpp::Element getElement() {
      this = TStdFunctionCall(result) or
      this = TStdMacroInvocation(result)
    }

    /**
     * Get an expression that represents the call to the standard function or macro.
     * 
     * In the case of a macro, the result is determined by the `InferMacroExpansionArguments`
     * config module.
     */
    cpp::Expr getExpr() {
      this = TStdFunctionCall(result) or
      exists(MacroInvocation mi |
        this = TStdMacroInvocation(mi) and
        result = InferExpansion::inferExpr(mi)
      )
    }
  }
}

/** Specify the name of your function as a predicate */
private signature string getPrefix();

/**
 * A module to generate a config for `StdFunctionOrMacro` based on a prefix satisfying the interface
 * of `InferMacroExpansionArguments`.
 *
 * For instance, if an implementation uses `#define readlink(...) __foo_readlink(...)` then this module
 * can be used to tell `StdFunctionOrMacro` to look for `__foo_readlink` based on the prefix `__foo_`.
 */
private module PrefixedFunctionWrapperMacro<getPrefix/0 getPfx> {
  bindingset[mi, argumentIdx]
  cpp::Expr inferArgument(cpp::MacroInvocation mi, int argumentIdx) {
    result = getFunctionCall(mi).getArgument(argumentIdx)
  }

  bindingset[mi]
  cpp::Expr inferExpr(cpp::MacroInvocation mi) {
    result = getFunctionCall(mi)
  }

  bindingset[mi]
  private cpp::FunctionCall getFunctionCall(cpp::MacroInvocation mi) {
    result = mi.getExpr() and
    result.getTarget().hasName(getPfx() + mi.getMacroName())
  }
}
