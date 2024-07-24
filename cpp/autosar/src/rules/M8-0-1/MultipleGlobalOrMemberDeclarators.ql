/**
 * @id cpp/autosar/multiple-global-or-member-declarators
 * @name M8-0-1: Multiple declarations in the same global or member declaration sequence
 * @description An init-declarator-list or a member-declarator-list shall consist of a single
 *              init-declarator or member-declarator respectively.
 * @kind problem
 * @precision medium
 * @problem.severity recommendation
 * @tags external/autosar/id/m8-0-1
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.multipleglobalormemberdeclarators.MultipleGlobalOrMemberDeclarators

class MultipleGlobalOrMemberDeclaratorsQuery extends MultipleGlobalOrMemberDeclaratorsSharedQuery
{
  MultipleGlobalOrMemberDeclaratorsQuery() {
    this = InitializationPackage::multipleGlobalOrMemberDeclaratorsQuery()
  }
}
