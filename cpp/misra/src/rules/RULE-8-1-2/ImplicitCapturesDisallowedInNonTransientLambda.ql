/**
 * @id cpp/misra/implicit-captures-disallowed-in-non-transient-lambda
 * @name RULE-8-1-2: Variables should be captured explicitly in a non-transient lambda
 * @description Explicit captures in lambdas which are "stored" clarifies dependencies that must be
 *              managed for memory management and safety.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-1-2
 *       scope/single-translation-unit
 *       readability
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Lambda
import TransientLambda<ImplicitCaptureLambdaExpr>
import PathProblem

from ImplicitCaptureLambdaExpr lambda, Element store, LambdaCapture capture, string reason
where
  not isExcluded(lambda, Expressions2Package::implicitCapturesDisallowedInNonTransientLambdaQuery()) and
  isStored(lambda, store, reason) and
  capture = lambda.getImplicitCapture()
select lambda, lambda, store,
  "Lambda implicitly captures $@ but is not considered a transient lambda because it is " + reason +
    ", resulting in obfuscated lifetimes.", capture, capture.getField().getName()
