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

/**
 * Holds if the `identifierName` has conflicting declarations.
 */
predicate isExternalIdentifierNotUnique(string identifierName) {
  // More than one declaration with this name
  count(Declaration d | d.getName() = identifierName) > 1 and
  // At least one declaration is an external identifier
  exists(ExternalIdentifiers e | e.getName() = identifierName)
}

/**
 * Holds if the `Declaration` `d` is conflicting with an external identifier.
 */
predicate isConflictingDeclaration(Declaration d, string name) {
  isExternalIdentifierNotUnique(name) and
  d.getName() = name
}

/**
 * An external identifier which is not uniquely defined in the source code.
 */
class NotUniqueExternalIdentifier extends ExternalIdentifiers {
  NotUniqueExternalIdentifier() { isExternalIdentifierNotUnique(getName()) }

  Declaration getAConflictingDeclaration() {
    not result = this and
    isConflictingDeclaration(result, getName())
  }
}

from NotUniqueExternalIdentifier e, Declaration de
where
  not isExcluded(de, Declarations6Package::identifiersWithExternalLinkageNotUniqueQuery()) and
  not isExcluded(e, Declarations6Package::identifiersWithExternalLinkageNotUniqueQuery()) and
  de = e.getAConflictingDeclaration()
select de, "Identifier conflicts with external identifier $@", e, e.getName()
