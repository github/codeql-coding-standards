/**
 * @id cpp/autosar/identifier-hiding
 * @name A2-10-1: An identifier declared in an inner scope shall not hide an identifier declared in an outer scope
 * @description Use of an identifier declared in an inner scope with an identical name to an
 *              identifier in an outer scope can lead to inadvertent errors if the incorrect
 *              identifier is modified.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-10-1
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.identifierhidden.IdentifierHidden

class IdentifierHidingCQuery extends IdentifierHiddenSharedQuery {
  IdentifierHidingCQuery() { this = NamingPackage::identifierHidingQuery() }
}
