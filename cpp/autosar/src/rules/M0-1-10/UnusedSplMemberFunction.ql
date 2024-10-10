/**
 * @id cpp/autosar/unused-spl-member-function
 * @name M0-1-10: Every defined function should be called at least once
 * @description Uncalled functions complicate the program and can indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision medium
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

from UnusedFunctions::UnusedSplMemberFunction unusedSplMemFunction, string name
where
  not isExcluded(unusedSplMemFunction, DeadCodePackage::unusedFunctionQuery()) and
  (
    if exists(unusedSplMemFunction.getQualifiedName())
    then name = unusedSplMemFunction.getQualifiedName()
    else name = unusedSplMemFunction.getName()
  ) and
  not unusedSplMemFunction.isDeleted()
select unusedSplMemFunction,
  "Special member function " + name + " is " + unusedSplMemFunction.getDeadCodeType()
