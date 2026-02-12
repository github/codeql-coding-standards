/**
 * @id cpp/autosar/unused-local-variable
 * @name M0-1-3: A project shall not contain unused local variables
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
import codingstandards.cpp.deadcode.UnusedVariables

// 10.1, 41.0
// 10.9, 45.9
// 11.0, 52.3
// 13.1, 59.3
from ThirdPassUnused::UnusedLocalVariable v
where not isExcluded(v, DeadCodePackage::unusedLocalVariableQuery())
select v, "Local variable '" + v.getName() + "' in '" + v.getFunction().getName() + "' is not used."
