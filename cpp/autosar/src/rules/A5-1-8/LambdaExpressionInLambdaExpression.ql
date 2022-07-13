/**
 * @id cpp/autosar/lambda-expression-in-lambda-expression
 * @name A5-1-8: Lambda expressions should not be defined inside another lambda expression
 * @description A lambda expression defined inside another lambda expression decreases the
 *              readability of the code.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a5-1-8
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from LambdaExpression inner, LambdaExpression outer
where
  not isExcluded(inner, LambdasPackage::lambdaExpressionInLambdaExpressionQuery()) and
  inner.getEnclosingFunction() = outer.getLambdaFunction()
select inner, "Lambda expression is defined in lambda $@.", outer, "expression"
