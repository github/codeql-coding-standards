/**
 * Provides a library which includes a `problems` predicate for reporting lambdas
 * whose captures are no longer pointing to valid objects after a move that extends
 * the lambdas life-time.
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class DanglingCaptureWhenReturningLambdaObjectSharedQuery extends Query { }

Query getQuery() { result instanceof DanglingCaptureWhenReturningLambdaObjectSharedQuery }

/** A lambda capture that can dangle when the lifetime of the lambda is extended. */
class PotentiallyDanglingCapture extends LambdaCapture {
  string name;

  PotentiallyDanglingCapture() {
    this.isCapturedByReference() and
    (
      // The name assigned to a captured this is `(captured this)` so we explicitly
      // set the name to `this` for reporting purposes.
      this.getInitializer() instanceof ThisExpr and name = "this"
      or
      exists(Variable v |
        this.getInitializer() = v.getAnAccess() and
        (
          v instanceof LocalVariable
          or
          v instanceof Parameter and not v.getType() instanceof ReferenceType
          or
          v instanceof MemberVariable
        ) and
        name = v.getName()
      )
    )
  }

  string getName() { result = name }
}

query predicate problems(
  ReturnStmt returnStmt, string message, LambdaExpression lambda, string lambdaDesc,
  PotentiallyDanglingCapture danglingCapture, string danglingCaptureDesc
) {
  not isExcluded(returnStmt, getQuery()) and
  lambda.getACapture() = danglingCapture and
  (
    DataFlow::localExprFlow(lambda, returnStmt.getExpr())
    or
    // implement a rough heuristic to catch the results of constructors (such as std::function's)
    // which take an argument that has a dangling capture and flow to a return statement
    exists(ConstructorCall cc |
      DataFlow::localExprFlow(lambda, cc.getAnArgument()) and
      DataFlow::localExprFlow(cc, returnStmt.getExpr())
    )
  ) and
  message = "Returning lambda $@ with potentially dangling capture $@." and
  lambdaDesc = "object" and
  danglingCaptureDesc = danglingCapture.getName()
}
