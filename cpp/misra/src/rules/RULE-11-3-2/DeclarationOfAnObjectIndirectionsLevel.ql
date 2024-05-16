/**
 * @id cpp/misra/declaration-of-an-object-indirections-level
 * @name RULE-11-3-2: The declaration of an object should contain no more than two levels of pointer indirection
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-11-3-2
 *       readability
 *       maintainability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.donotusemorethantwolevelsofpointerindirection.DoNotUseMoreThanTwoLevelsOfPointerIndirection

class DeclarationOfAnObjectIndirectionsLevelQuery extends DoNotUseMoreThanTwoLevelsOfPointerIndirectionSharedQuery {
  DeclarationOfAnObjectIndirectionsLevelQuery() {
    this = ImportMisra23Package::declarationOfAnObjectIndirectionsLevelQuery()
  }
}
