/**
 * @id cpp/autosar/lambda-with-implicit-non-void-return-type
 * @name A5-1-6: Return type of a non-void return type lambda expression should be explicitly specified
 * @description Providing an explicit non-void return type helps prevent confusion on the type being
 *              returned.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a5-1-6
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from LambdaExpression e
where
  not isExcluded(e, LambdasPackage::lambdaWithImplicitNonVoidReturnTypeQuery()) and
  not e.getLambdaFunction().getType() instanceof VoidType and
  not e.returnTypeIsExplicit()
select e, "Lambda expression with implicit non-void return type. "
