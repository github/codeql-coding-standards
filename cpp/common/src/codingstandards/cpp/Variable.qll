import cpp
import semmle.code.cpp.PODType03

/** A variable of type scalar. */
class ScalarVariable extends Variable {
  ScalarVariable() { isScalarType03(this.getType()) }
}

/**
 * Returns the target variable of a `VariableAccess`.
 * If the access is a field access, then the target is the `Variable` of the qualifier.
 * If the access is an array access, then the target is the array base.
 */
Variable getAddressOfExprTargetBase(AddressOfExpr expr) {
  result = expr.getOperand().(ValueFieldAccess).getQualifier().(VariableAccess).getTarget()
  or
  not expr.getOperand() instanceof ValueFieldAccess and
  result = expr.getOperand().(VariableAccess).getTarget()
  or
  result = expr.getOperand().(ArrayExpr).getArrayBase().(VariableAccess).getTarget()
}
