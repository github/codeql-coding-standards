/**
 * @id cpp/autosar/unused-type-declarations
 * @name A0-1-6: There should be no unused type declarations
 * @description Unused type declarations are either redundant or indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-6
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.unusedtypedeclarations.UnusedTypeDeclarations

class UnusedTypeDeclarationsQuery extends UnusedTypeDeclarationsSharedQuery {
  UnusedTypeDeclarationsQuery() { this = DeadCodePackage::unusedTypeDeclarationsQuery() }
}
