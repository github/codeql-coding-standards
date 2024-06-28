/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ReturnReferenceOrPointerToAutomaticLocalVariable_sharedSharedQuery extends Query { }

Query getQuery() {
  result instanceof ReturnReferenceOrPointerToAutomaticLocalVariable_sharedSharedQuery
}

query predicate problems(
  ReturnStmt rs, string message, Function f, string f_string, Variable auto, string auto_string
) {
  exists(VariableAccess va, string returnType |
    not isExcluded(rs, getQuery()) and
    f = rs.getEnclosingFunction() and
    (
      f.getType() instanceof ReferenceType and va = rs.getExpr() and returnType = "reference"
      or
      f.getType() instanceof PointerType and
      va = rs.getExpr().(AddressOfExpr).getOperand() and
      returnType = "pointer"
    ) and
    auto = va.getTarget() and
    not auto.isStatic() and
    not f.isCompilerGenerated() and
    not auto.getType() instanceof ReferenceType and
    message = "The $@ returns a " + returnType + "to an $@ variable" and
    f_string = f.getName() and
    auto_string = "automatic"
  )
}
