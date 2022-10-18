/**
 * @id c/misra/function-over-function-like-macro
 * @name DIR-4-9: A function should be used in preference to a function-like macro where they are interchangeable
 * @description Using a function-like macro instead of a function can lead to unexpected program
 *              behaviour.
 * @kind problem
 * @precision medium
 * @problem.severity recommendation
 * @tags external/misra/id/dir-4-9
 *       external/misra/audit
 *       maintainability
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.FunctionLikeMacro
import codingstandards.cpp.Naming

predicate omission(Macro i) { Naming::Cpp14::hasStandardLibraryMacroName(i.getName()) }

abstract class IrreplaceableFunctionLikeMacro extends FunctionLikeMacro { }

private class AsmArgumentInvoked extends IrreplaceableFunctionLikeMacro {
  AsmArgumentInvoked() {
    any(AsmStmt s).getLocation().subsumes(this.getAnInvocation().getLocation())
  }
}

private class OnlyConstantNumericInvoked extends IrreplaceableFunctionLikeMacro {
  OnlyConstantNumericInvoked() {
    forex(MacroInvocation mi | mi = this.getAnInvocation() |
      mi.getUnexpandedArgument(_).regexpMatch("\\d+")
    )
  }
}

private class KnownIrreplaceableFunctionLikeMacro extends IrreplaceableFunctionLikeMacro {
  KnownIrreplaceableFunctionLikeMacro() {
    this.getName() in ["UNUSED", "__has_builtin", "MIN", "MAX"]
  }
}

private class UsedToStaticInitialize extends IrreplaceableFunctionLikeMacro {
  UsedToStaticInitialize() {
    any(StaticStorageDurationVariable v).getInitializer().getExpr() =
      this.getAnInvocation().getExpr()
  }
}

private class FunctionLikeMacroWithOperatorArgument extends IrreplaceableFunctionLikeMacro {
  FunctionLikeMacroWithOperatorArgument() {
    exists(MacroInvocation mi | mi.getMacro() = this |
      mi.getUnexpandedArgument(_) = any(Operation op).getOperator()
    )
  }
}

abstract class UnsafeMacro extends FunctionLikeMacro { }

class ParameterNotUsedMacro extends UnsafeMacro {
  ParameterNotUsedMacro() {
    //parameter not used - has false positives on args that are not used but are substrings of other args
    exists(string p |
      p = this.getAParameter() and
      not this.getBody().regexpMatch(".*(\\s*|\\(|\\)|\\##)" + p + "(\\s*||\\)|\\(|\\##).*")
    )
  }
}

class ParameterMoreThanOnceMacro extends UnsafeMacro {
  ParameterMoreThanOnceMacro() {
    //parameter used more than once
    exists(string p |
      p = this.getAParameter() and
      exists(int i, string newstr |
        newstr = this.getBody().replaceAll(p, "") and
        i = ((this.getBody().length() - newstr.length()) / p.length()) and
        i > 1
      )
    )
  }
}

predicate partOfConstantExpr(MacroInvocation i) {
  exists(Expr e |
    e.isConstant() and
    not i.getExpr() = e and
    i.getExpr().getParent+() = e
  )
}

from FunctionLikeMacro m
where
  not isExcluded(m, Preprocessor6Package::functionOverFunctionLikeMacroQuery()) and
  not omission(m) and
  m instanceof UnsafeMacro and
  not m instanceof IrreplaceableFunctionLikeMacro and
  //function call not allowed in a constant expression (where constant expr is parent)
  forall(MacroInvocation i | i = m.getAnInvocation() | not partOfConstantExpr(i))
select m, "Macro used when function call would be preferred."
