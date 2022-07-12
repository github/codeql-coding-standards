/**
 * @id cpp/autosar/single-use-local-pod-variable
 * @name M0-1-4: A project shall not contain non-volatile local POD variables having only one use
 * @description Single use local POD variables complicate the program and can indicate a possible
 *              mistake on the part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m0-1-4
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.deadcode.UnusedVariables
import SingleUsePODVariable

from PotentiallyUnusedLocalVariable v
where
  not isExcluded(v, DeadCodePackage::singleUseLocalPODVariableQuery()) and
  isSingleUseNonVolatilePODVariable(v)
select v, "Local POD variable " + v.getName() + " in " + v.getFunction().getName() + " is only $@.",
  getSingleUse(v), "used once"
