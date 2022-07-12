/**
 * @id cpp/autosar/lambda-expression-without-parameter-list
 * @name A5-1-3: Parameter list (possibly empty) shall be included in every lambda expression
 * @description An explicit parameter list disambiguates lambda expressions from other C++
 *              constructs and it is therefore recommended to include it in every lambda expression.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a5-1-3
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from LambdaExpression lambda, Operator lambdaFunction
where
  not isExcluded(lambda, LambdasPackage::lambdaExpressionWithoutParameterListQuery()) and
  lambdaFunction = lambda.getLambdaFunction() and
  not lambdaFunction.isAffectedByMacro() and
  // The extractor doesn't store the syntactic information whether the parameter list
  // is enclosed in parenthesis. Therefore we cannot determine if the parameter list is
  // explicitly specified when the parameter list is empty.
  // The following is a workaround that relies on the location of the generated function
  // and its function body to determine if a parameter list is provided.
  // If this is not the case then the function and its body start on the same line and column.
  exists(Location fLoc, Location bodyLoc |
    fLoc = lambdaFunction.getLocation() and
    bodyLoc = lambdaFunction.getBlock().getLocation() and
    fLoc.getStartLine() = bodyLoc.getStartLine() and
    fLoc.getStartColumn() = bodyLoc.getStartColumn() and
    fLoc.getFile() = bodyLoc.getFile()
  )
select lambda, "Lambda expression does not have explicit parameter list."
