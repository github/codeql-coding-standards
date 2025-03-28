/**
 * @id cpp/autosar/identical-lambda-expressions
 * @name A5-1-9: Identical unnamed lambda expressions shall be replaced with a named function or a named lambda
 * @description Identical unnamed lambda expressions shall be replaced with a named function or a
 *              named lambda expression to improve code readability and maintainability.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a5-1-9
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import LambdaEquivalence

from LambdaExpression lambdaExpression, LambdaExpression otherLambdaExpression
where
  not isExcluded(lambdaExpression, LambdasPackage::identicalLambdaExpressionsQuery()) and
  not lambdaExpression = otherLambdaExpression and
  not lambdaExpression.isFromTemplateInstantiation(_) and
  not otherLambdaExpression.isFromTemplateInstantiation(_) and
  getLambdaHashCons(lambdaExpression) = getLambdaHashCons(otherLambdaExpression) and
  // Do not report lambdas produced by the same macro in different invocations
  not exists(Macro m, MacroInvocation m1, MacroInvocation m2 |
    m1 = m.getAnInvocation() and
    m2 = m.getAnInvocation() and
    not m1 = m2 and // Lambdas in the same macro can be reported
    m1.getAnExpandedElement() = lambdaExpression and
    m2.getAnExpandedElement() = otherLambdaExpression
  )
select lambdaExpression, "Lambda expression is identical to $@ lambda expression.",
  otherLambdaExpression, "this"
