/**
 * @id cpp/misra/use-single-local-declarators
 * @name RULE-10-0-1: Multiple declarations in the same local statement
 * @description A declaration should not declare more than one variable or member variable.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-10-0-1
 *       readability
 *       maintainability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.multiplelocaldeclarators_shared.MultipleLocalDeclarators_shared

class UseSingleLocalDeclaratorsQuery extends MultipleLocalDeclarators_sharedSharedQuery {
  UseSingleLocalDeclaratorsQuery() {
    this = ImportMisra23Package::useSingleLocalDeclaratorsQuery()
  }
}
