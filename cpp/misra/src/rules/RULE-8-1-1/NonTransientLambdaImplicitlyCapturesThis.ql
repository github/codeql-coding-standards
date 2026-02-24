/**
 * @id cpp/misra/non-transient-lambda-implicitly-captures-this
 * @name RULE-8-1-1: A non-transient lambda shall not implicitly capture this
 * @description Using implicit capture for a lambda declared in a class will capture the `this`
 *              pointer and not the instance members, which can be suprising and result in undefined
 *              behavior past the object's lifetime.
 * @kind path-problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-1-1
 *       scope/single-translation-unit
 *       correctness
 *       readability
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Lambda
import TransientLambda<ImplicitThisCapturingLambdaExpr>
import PathProblem

from ImplicitThisCapturingLambdaExpr lambda, Element store, Class containingClass, string reason
where
  not isExcluded(lambda, Expressions2Package::nonTransientLambdaImplicitlyCapturesThisQuery()) and
  isStored(lambda, store, reason) and
  containingClass = lambda.getEnclosingDeclaration().getEnclosingElement*()
select lambda, lambda, store,
  "Lambda implicitly captures `this` pointer of $@, making its lifetime dependent on the lifetime of the class object, and the lambda is not considered transient because it is "
    + reason + ".", containingClass, containingClass.getName()
