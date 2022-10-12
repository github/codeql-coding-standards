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

predicate isOperator(string possible) {
  possible in [
      "+", "-", "*", "/", "%", "^", "&", "|", "~", "!", "=", "<", ">", "+=", "-=", "*=", "/=", "%=",
      "^=", "&=", "|=", "<<", ">>", ">>=", "<<=", "==", "!=", "<=", ">=", "<=>", "&&", "||", "++",
      "--", "->*", "->", "()", "[]"
    ]
}

//cases where we trust the choice
predicate omission(MacroInvocation i) {
  i.getFile() instanceof HeaderFile or
  Naming::Cpp14::hasStandardLibraryMacroName(i.getMacroName())
}

class UnsafeMacro extends FunctionLikeMacro {
  UnsafeMacro() {
    //parameter not used - has false positives on args that are not used but are substrings of other args
    exists(string p |
      p = this.getAParameter() and
      not this.getBody().regexpMatch(".*(\\s*|\\(||\\))" + p + "(\\s*||\\)|\\().*")
    )
    or
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

from MacroInvocation i
where
  not isExcluded(i, Preprocessor6Package::functionOverFunctionLikeMacroQuery()) and
  not omission(i) and
  i.getMacro() instanceof UnsafeMacro and
  //heuristic - macros with one arg only are easier to replace
  not exists(i.getUnexpandedArgument(1)) and
  //operator as arg omits function applicability
  not isOperator(i.getUnexpandedArgument(_)) and
  //static storage duration can only be initialized with constant
  not exists(StaticStorageDurationVariable v | i.getExpr() = v.getAnAssignedValue()) and
  //function call not allowed in a constant expression (where constant expr is parent)
  not exists(Expr e |
    e.isConstant() and
    not i.getExpr() = e and
    i.getExpr().getParent+() = e
  ) and
  forall(string arg | arg = i.getUnexpandedArgument(_) | exists(Expr e | arg = e.toString()))
select i, "Macro invocation used when function call would be preferred."
