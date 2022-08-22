/**
 * @id cpp/autosar/asm-declaration-used
 * @name A7-4-1: The asm declaration shall not be used
 * @description The asm declaration shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-4-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from AsmStmt a
where not isExcluded(a, BannedSyntaxPackage::asmDeclarationUsedQuery())
select a, "Use of asm declaration"
