/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.IrreplaceableFunctionLikeMacro

abstract class FunctionLikeMacrosDefined_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof FunctionLikeMacrosDefined_sharedSharedQuery }

predicate partOfConstantExpr(MacroInvocation i) {
  exists(Expr e |
    e.isConstant() and
    not i.getExpr() = e and
    i.getExpr().getParent+() = e
  )
}

query predicate problems(FunctionLikeMacro m, string message) {
  not isExcluded(m, getQuery()) and
  not m instanceof IrreplaceableFunctionLikeMacro and
  //macros can have empty body
  not m.getBody().length() = 0 and
  //function call not allowed in a constant expression (where constant expr is parent)
  forall(MacroInvocation i | i = m.getAnInvocation() | not partOfConstantExpr(i)) and
  message = "Macro used instead of a function."
}
