/**
 * @id c/misra/identifiers-in-the-same-name-space-unambiguous
 * @name DIR-4-5: Identifiers in the same name space with overlapping visibility should be typographically unambiguous
 * @description Typographically ambiguous identifiers can lead to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/misra/id/dir-4-5
 *       readability
 *       maintainability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.differentidentifiersnottypographicallyunambiguous.DifferentIdentifiersNotTypographicallyUnambiguous

class IdentifiersInTheSameNameSpaceUnambiguousQuery extends DifferentIdentifiersNotTypographicallyUnambiguousSharedQuery {
  IdentifiersInTheSameNameSpaceUnambiguousQuery() {
    this = SyntaxPackage::identifiersInTheSameNameSpaceUnambiguousQuery()
  }
}
