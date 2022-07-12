/**
 * @id cpp/autosar/unused-member-variable
 * @name M0-1-3: A project shall not contain unused member variables
 * @description Unused variables complicate the program and can indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m0-1-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.FunctionEquivalence
import codingstandards.cpp.deadcode.UnusedVariables

from PotentiallyUnusedMemberVariable v
where
  not isExcluded(v, DeadCodePackage::unusedMemberVariableQuery()) and
  // No variable access
  not exists(v.getAnAccess()) and
  // No explicit initialization in a constructor
  not exists(UserProvidedConstructorFieldInit cfi | cfi.getTarget() = v)
select v, "Member variable " + v.getName() + " is unused."
