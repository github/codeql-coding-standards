/**
 * @id cpp/autosar/usage-of-assembler-not-documented
 * @name M7-4-1: All usage of assembler shall be documented
 * @description Assembly language code is implementation-defined and, therefore, is not portable.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m7-4-1
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/audit
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from AsmStmt a
where
  not isExcluded(a, BannedLibrariesPackage::usageOfAssemblerNotDocumentedQuery()) and
  not exists(Comment c | c.getCommentedElement() = a) and
  not a.isAffectedByMacro()
select a, "Use of assembler is not documented."
