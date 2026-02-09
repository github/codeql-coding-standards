/**
 * This module intends to reduce the difficulty of handling the pattern where implementations
 * implement a function as a macro: the class `StdFunctionOrMacro<...>::Call` matches both std
 * function calls as well as std function macro expansions.
 *
 * For instance, `atomic_init` may be implemented as a function, but is also implemented as a
 * complicated macro on some platforms. This module aids in finding calls to any standard function
 * which may be a macro.
 *
 * Since a macro can be defined to expand to any expression, we cannot know generally which
 * expanded expressions in `f(x, y)` correspond to arguments `x` or `y`. To handle this, implement
 * the module `InferMacroExpansionArguments`.
 *
 * To match a function of a particular name create a predicate for the name you wish to match. For
 * instance:
 *
 * ```codeql
 *   private string atomicInit() { result = "atomic_init" }
 *
 *   from StdFunctionOrMacro<YourInferenceModule, atomicInit/0>::Call c
 *   select c.getArgument(0)
 * ```
 */

import cpp as cpp

private string atomicInit() { result = "atomic_init" }

class AtomicInitCall = StdFunctionOrMacro<InferAtomicMacroArgs, atomicInit/0>::Call;

/** Specify the name of your function as a predicate */
private signature string getName();

/** Signature module to implement custom argument resolution behavior in expanded macros */
private signature module InferMacroExpansionArguments {
  bindingset[mi, argumentIdx]
  cpp::Expr inferArgument(cpp::MacroInvocation mi, int argumentIdx);
}

private module InferAtomicMacroArgs implements InferMacroExpansionArguments {
  bindingset[pattern]
  private cpp::Expr getMacroVarInitializer(cpp::MacroInvocation mi, string pattern) {
    exists(cpp::VariableDeclarationEntry decl |
      mi.getAGeneratedElement() = decl and
      decl.getName().matches(pattern) and
      result = decl.getDeclaration().getInitializer().getExpr()
    )
  }

  bindingset[mi, argumentIdx]
  cpp::Expr inferArgument(cpp::MacroInvocation mi, int argumentIdx) {
    result = mi.getExpr().(cpp::FunctionCall).getArgument(argumentIdx)
    or
    if
      argumentIdx = 0 and
      exists(getMacroVarInitializer(mi, "__atomic_%_ptr"))
    then result = getMacroVarInitializer(mi, "__atomic_%_ptr")
    else
      if
        argumentIdx = [1, 2] and
        exists(getMacroVarInitializer(mi, "__atomic_%_tmp"))
      then result = getMacroVarInitializer(mi, "__atomic_%_tmp")
      else
        exists(cpp::FunctionCall fc |
          fc = mi.getAnExpandedElement() and
          fc.getTarget().getName().matches("%atomic_%") and
          result = fc.getArgument(argumentIdx)
        )
  }
}

private string atomicReadOrWriteName() {
  result =
    [
        "atomic_load",
        "atomic_store",
        "atomic_fetch_" + ["add", "sub", "or", "xor", "and"],
        "atomic_exchange",
        "atomic_compare_exchange_" + ["strong", "weak"]
      ] + ["", "_explicit"]
}

class AtomicReadOrWriteCall =
  StdFunctionOrMacro<InferAtomicMacroArgs, atomicReadOrWriteName/0>::Call;

private string atomicallySequencedName() {
  result =
    [
      "atomic_thread_fence",
      "atomic_signal_fence",
      "atomic_flag_clear_explicit",
      "atomic_flag_test_and_set_explicit",
    ]
  or
  result = atomicReadOrWriteName() and
  result.matches("%_explicit")
}

/** A `stdatomic.h` function which accepts a `memory_order` value as a parameter. */
class AtomicallySequencedCall extends StdFunctionOrMacro<InferAtomicMacroArgs, atomicallySequencedName/0>::Call
{
  cpp::Expr getAMemoryOrderArgument() {
    if getName() = "atomic_compare_exchange_" + ["strong", "weak"] + "_explicit"
    then result = getArgument(getNumberOfArguments() - [1, 2])
    else result = getArgument(getNumberOfArguments() - 1)
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
 *   from StdFunctionOrMacro<YourInferenceModule, atomicInit/0>::Call c
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

    Expr getAnArgument() {
      exists(int i |
        i = [0 .. getNumberOfArguments()] and
        result = getArgument(i)
      )
    }

    string getName() {
      exists(FunctionCall fc |
        this = TStdFunctionCall(fc) and
        result = fc.getTarget().getName()
      )
      or
      exists(MacroInvocation mi |
        this = TStdMacroInvocation(mi) and
        result = mi.getMacroName()
      )
    }

    string toString() {
      this = TStdFunctionCall(_) and
      result = "Standard function call"
      or
      this = TStdMacroInvocation(_) and
      result = "Invocation of a standard function implemented as a macro"
    }

    int getNumberOfArguments() {
      exists(FunctionCall fc |
        this = TStdFunctionCall(fc) and
        result = fc.getTarget().getNumberOfParameters()
      )
      or
      exists(MacroInvocation mi |
        this = TStdMacroInvocation(mi) and
        result = count(int i | i = [0 .. 10] and exists(InferExpansion::inferArgument(mi, i)))
      )
    }

    Expr getExpr() {
      this = TStdFunctionCall(result)
      or
      exists(MacroInvocation mi |
        this = TStdMacroInvocation(mi) and
        result = mi.getExpr()
      )
    }
  }
}
