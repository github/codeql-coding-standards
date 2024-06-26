/**
 * @id cpp/misra/asm-declaration-shall-not-be-used
 * @name RULE-10-4-1: The asm declaration shall not be used
 * @description The asm declaration shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-4-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.asmdeclarationused_shared.AsmDeclarationUsed_shared

class AsmDeclarationShallNotBeUsedQuery extends AsmDeclarationUsed_sharedSharedQuery {
  AsmDeclarationShallNotBeUsedQuery() {
    this = ImportMisra23Package::asmDeclarationShallNotBeUsedQuery()
  }
}
