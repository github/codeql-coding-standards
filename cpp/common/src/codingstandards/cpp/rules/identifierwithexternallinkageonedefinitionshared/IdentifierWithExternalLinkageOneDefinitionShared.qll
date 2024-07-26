/**
 * Provides a library with a `problems` predicate for the following issue:
 * An identifier with multiple definitions in different translation units
 * leads to undefined behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Linkage

abstract class IdentifierWithExternalLinkageOneDefinitionSharedSharedQuery extends Query { }

Query getQuery() { result instanceof IdentifierWithExternalLinkageOneDefinitionSharedSharedQuery }

query predicate problems(DeclarationEntry de1, string message, DeclarationEntry de2, string de2Str) {
  exists(Declaration d |
    not isExcluded(de1, getQuery()) and
    hasExternalLinkage(d) and
    d.isTopLevel() and
    d = de1.getDeclaration() and
    d = de2.getDeclaration() and
    de1 != de2 and
    de1.isDefinition() and
    de2.isDefinition() and
    // exceptions
    not d instanceof TemplateClass and
    (d instanceof Function implies not d.(Function).isInline()) and
    // Apply an ordering based on location to enforce that (de1, de2) = (de2, de1) and we only report (de1, de2).
    (
      de1.getFile().getAbsolutePath() < de2.getFile().getAbsolutePath()
      or
      de1.getFile().getAbsolutePath() = de2.getFile().getAbsolutePath() and
      de1.getLocation().getStartLine() < de2.getLocation().getStartLine()
    ) and
    message = "The identifier " + de1.getName() + " has external linkage and is redefined $@." and
    de2Str = "here"
  )
}
