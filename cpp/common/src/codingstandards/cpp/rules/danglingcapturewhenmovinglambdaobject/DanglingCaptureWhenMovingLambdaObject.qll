/**
 * Provides a library which includes a `problems` predicate for reporting lambdas
 * whose captures are no longer pointing to valid objects after a move that extends
 * the lambdas life-time.
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Expr

abstract class DanglingCaptureWhenMovingLambdaObjectSharedQuery extends Query { }

Query getQuery() { result instanceof DanglingCaptureWhenMovingLambdaObjectSharedQuery }

/** A global, namespace or member variable */
class NonLocalScopeVariable extends Variable {
  NonLocalScopeVariable() {
    this instanceof GlobalOrNamespaceVariable
    or
    this instanceof MemberVariable
  }

  string getKind() {
    this instanceof GlobalVariable and result = "global"
    or
    this instanceof NamespaceVariable and result = "namespace"
    or
    this instanceof MemberVariable and result = "member"
  }
}

query predicate problems(
  AnyAssignExpr assign, string message, LambdaExpression lambda, string lambdaDesc,
  LocalScopeVariable localVariable, string localVariableDesc,
  NonLocalScopeVariable nonLocalVariable, string nonLocalVariableDesc
) {
  not isExcluded(assign, getQuery()) and
  DataFlow::localExprFlow(lambda, assign.getRValue()) and
  exists(LambdaCapture capture |
    lambda.getACapture() = capture and
    capture.getInitializer().(VariableAccess).getTarget() = localVariable and
    capture.isCapturedByReference()
  ) and
  assign.getLValue().(VariableAccess).getTarget() = nonLocalVariable and
  message =
    "Assigning lambda $@ that captures local object $@ by reference to " +
      nonLocalVariable.getKind() + " variable $@ with a greater lifetime." and
  lambdaDesc = "object" and
  localVariableDesc = localVariable.getName() and
  nonLocalVariableDesc = nonLocalVariable.getName()
}
