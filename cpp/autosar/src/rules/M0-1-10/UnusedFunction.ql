/**
 * @id cpp/autosar/unused-function
 * @name M0-1-10: Every defined function should be called at least once
 * @description Uncalled functions complicate the program and can indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m0-1-10
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.deadcode.UnusedFunctions

from UnusedFunctions::UnusedFunction unusedFunction, string name
where
  not isExcluded(unusedFunction, DeadCodePackage::unusedFunctionQuery()) and
  (
    if exists(unusedFunction.getQualifiedName())
    then name = unusedFunction.getQualifiedName()
    else name = unusedFunction.getName()
  ) and
  not unusedFunction.isDeleted()
select unusedFunction, "Function " + name + " is " + unusedFunction.getDeadCodeType()
