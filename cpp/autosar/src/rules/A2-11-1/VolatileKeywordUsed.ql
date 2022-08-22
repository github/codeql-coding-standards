/**
 * @id cpp/autosar/volatile-keyword-used
 * @name A2-11-1: Volatile keyword shall not be used
 * @description The volatile keyword shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a2-11-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Variable v
where
  not isExcluded(v, BannedSyntaxPackage::volatileKeywordUsedQuery()) and
  v.getType().isVolatile()
select v, "Variable " + v.getName() + " is declared with volatile specifier"
