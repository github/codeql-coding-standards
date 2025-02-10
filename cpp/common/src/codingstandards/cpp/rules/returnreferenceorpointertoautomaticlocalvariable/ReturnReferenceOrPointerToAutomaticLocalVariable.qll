/**
 * Provides a library with a `problems` predicate for the following issue:
 * Functions that return a reference or a pointer to an automatic variable (including
 * parameters) potentially lead to undefined behaviour.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ReturnReferenceOrPointerToAutomaticLocalVariableSharedQuery extends Query { }

Query getQuery() { result instanceof ReturnReferenceOrPointerToAutomaticLocalVariableSharedQuery }

query predicate problems(
  ReturnStmt rs, string message, Function f, string f_string, StackVariable auto, string auto_string
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
