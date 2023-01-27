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
import codingstandards.c.IrreplaceableFunctionLikeMacro

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
  not m instanceof IrreplaceableFunctionLikeMacro and
  //macros can have empty body
  not m.getBody().length() = 0 and
  //function call not allowed in a constant expression (where constant expr is parent)
  forall(MacroInvocation i | i = m.getAnInvocation() | not partOfConstantExpr(i))
select m, "Macro used instead of a function."
