/**
 * @id cpp/autosar/implicit-lambda-capture
 * @name A5-1-2: Variables shall not be implicitly captured in a lambda expression
 * @description Explicitly capturing variables used in a lambda expression helps with documenting
 *              the intention of the author.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a5-1-2
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from VariableAccess access, LambdaExpression lambdaExpression, string name
where
  not isExcluded(lambdaExpression, LambdasPackage::implicitLambdaCaptureQuery()) and
  access.getEnclosingFunction() = lambdaExpression.getLambdaFunction() and
  // Variables with non-automatic storage duration will not be captured by a lambda
  // (see [expr.prim.lambda] paragraph 12) and aren't modelled by `LambdaCapture` so
  // we don't have to explicity handle the exception case.
  exists(LambdaCapture capture |
    access.getTarget() = capture.getField() and
    capture.isImplicit()
  ) and
  if access.getTarget().getName() = "(captured this)"
  then name = "this"
  else name = access.getTarget().getName()
select lambdaExpression, "Variable $@ is implicitly captured in lambda expression.", access, name
