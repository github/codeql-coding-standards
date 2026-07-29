/**
 * @id cpp/misra/string-literal-possibly-modified-audit
 * @name RULE-4-1-3: Audit: string literal possibly modified through non-const pointer
 * @description Assigning a string literal to a non-const pointer may lead to undefined behaviour if
 *              the string is modified through that pointer.
 * @kind problem
 * @precision low
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/audit
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.stringliteralsassignedtononconstantpointersshared.StringLiteralsAssignedToNonConstantPointersShared

module StringLiteralPossiblyModifiedAuditConfig implements
  StringLiteralsAssignedToNonConstantPointersSharedConfigSig
{
  Query getQuery() { result = UndefinedPackage::stringLiteralPossiblyModifiedAuditQuery() }
}

import StringLiteralsAssignedToNonConstantPointersShared<StringLiteralPossiblyModifiedAuditConfig>
