/**
 * @id cpp/autosar/typedef-specifier-used
 * @name A7-1-6: The typedef specifier shall not be used
 * @description The typedef specifier shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-1-6
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from CTypedefType t
where not isExcluded(t, BannedSyntaxPackage::typedefSpecifierUsedQuery())
select t, "Use of typedef"
