/**
 * @id cpp/misra/use-single-global-or-member-declarators
 * @name RULE-10-0-1: Multiple declarations in the same global or member declaration sequence
 * @description A declaration should not declare more than one variable or member variable.
 * @kind problem
 * @precision medium
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
import codingstandards.cpp.rules.multipleglobalormemberdeclarators_shared.MultipleGlobalOrMemberDeclarators_shared

class UseSingleGlobalOrMemberDeclaratorsQuery extends MultipleGlobalOrMemberDeclarators_sharedSharedQuery {
  UseSingleGlobalOrMemberDeclaratorsQuery() {
    this = ImportMisra23Package::useSingleGlobalOrMemberDeclaratorsQuery()
  }
}
