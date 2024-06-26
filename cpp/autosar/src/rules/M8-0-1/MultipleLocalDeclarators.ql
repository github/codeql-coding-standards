/**
 * @id cpp/autosar/multiple-local-declarators
 * @name M8-0-1: Multiple declarations in the same local statement
 * @description An init-declarator-list or a member-declarator-list shall consist of a single
 *              init-declarator or member-declarator respectively.
 * @kind problem
 * @precision very-high
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
import codingstandards.cpp.rules.multiplelocaldeclarators_shared.MultipleLocalDeclarators_shared

class MultipleLocalDeclaratorsQuery extends MultipleLocalDeclarators_sharedSharedQuery {
  MultipleLocalDeclaratorsQuery() {
    this = InitializationPackage::multipleLocalDeclaratorsQuery()
  }
}
