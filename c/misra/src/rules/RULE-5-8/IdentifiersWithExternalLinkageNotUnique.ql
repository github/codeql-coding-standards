/**
 * @id c/misra/identifiers-with-external-linkage-not-unique
 * @name RULE-5-8: Identifiers that define objects or functions with external linkage shall be unique
 * @description Using non-unique identifiers can lead to developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-8
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers

from Declaration de, ExternalIdentifiers e
where
  not isExcluded(de, Declarations6Package::identifiersWithExternalLinkageNotUniqueQuery()) and
  not isExcluded(e, Declarations6Package::identifiersWithExternalLinkageNotUniqueQuery()) and
  not de = e and
  de.getName() = e.getName()
select de, "Identifier conflicts with external identifier $@", e, e.getName()
