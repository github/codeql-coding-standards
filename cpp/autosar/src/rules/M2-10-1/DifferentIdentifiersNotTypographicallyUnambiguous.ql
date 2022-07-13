/**
 * @id cpp/autosar/different-identifiers-not-typographically-unambiguous
 * @name M2-10-1: Different identifiers shall be typographically unambiguous
 * @description Typographically ambiguous identifiers can lead to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m2-10-1
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
import codingstandards.cpp.rules.differentidentifiersnottypographicallyunambiguous.DifferentIdentifiersNotTypographicallyUnambiguous

class DifferentIdentifiersNotTypographicallyUnambiguousQuery extends DifferentIdentifiersNotTypographicallyUnambiguousSharedQuery {
  DifferentIdentifiersNotTypographicallyUnambiguousQuery() {
    this = NamingPackage::differentIdentifiersNotTypographicallyUnambiguousQuery()
  }
}
