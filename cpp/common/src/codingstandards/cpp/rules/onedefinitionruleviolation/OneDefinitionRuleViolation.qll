/**
 * Provides a library which includes a `problems` predicate for reporting violations of the one-definition rule.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class OneDefinitionRuleViolationSharedQuery extends Query { }

Query getQuery() { result instanceof OneDefinitionRuleViolationSharedQuery }

query predicate problems(
  DeclarationEntry d1, string message, DeclarationEntry d2, string placeholder
) {
  not isExcluded(d1, getQuery()) and
  not isExcluded(d2, getQuery()) and
  d1 != d2 and
  d1.getDeclaration() = d2.getDeclaration() and
  d1.isDefinition() and
  d2.isDefinition() and
  d1.getFile().getAbsolutePath() < d2.getFile().getAbsolutePath() and
  // exclude parameters
  not d1.getDeclaration() instanceof Parameter and
  // exclude definitions part of a user type
  not exists(d1.getDeclaration().getDeclaringType()) and
  not exists(d2.getDeclaration().getDeclaringType()) and
  // exclude inline function without external linkage
  (
    d1.getDeclaration() instanceof Function
    implies
    (
      not d1.getDeclaration().(Function).isInline() and
      not d1.getDeclaration().(Function).hasSpecifier("extern")
    )
  ) and
  // exclusion based on [basic.def.odr:6] on are not considered because we cannot validate the requirement:
  // each definition of D shall consist of the same sequence of tokens.
  not d1.getDeclaration() instanceof Type and
  message = "A second definition of " + d1.getName() + " found $@ violates the one definition rule." and
  placeholder = "here"
}
