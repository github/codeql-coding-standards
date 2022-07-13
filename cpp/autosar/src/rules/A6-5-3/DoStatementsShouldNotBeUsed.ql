/**
 * @id cpp/autosar/do-statements-should-not-be-used
 * @name A6-5-3: Do statements should not be used
 * @description Do statements can be more prone to bugs than for or while loops, because the
 *              condition is not checked before the loop is executed.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a6-5-3
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from DoStmt ds
where not isExcluded(ds, LoopsPackage::doStatementsShouldNotBeUsedQuery())
select ds, "Use of do while loop."
