/**
 * @id c/misra/should-not-be-defined-with-external-linkage
 * @name RULE-8-7: Functions and objects should not be defined with external linkage if they are referenced in only one
 * @description Declarations with external linkage that are referenced in only one translation unit
 *              can indicate an intention to only have those identifiers accessible in that
 *              translation unit and accidental future accesses in other translation units can lead
 *              to confusing program behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-7
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Identifiers
import codingstandards.cpp.Scope

ExternalIdentifiers getExternalIdentifierTarget(NameQualifiableElement nqe) {
  result = nqe.(Access).getTarget()
  or
  result = nqe.(FunctionCall).getTarget()
}

/**
 * A reference to an external identifier, either as an `Access` or a `FunctionCall`.
 */
class ExternalIdentifierReference extends NameQualifiableElement {
  ExternalIdentifierReference() { exists(getExternalIdentifierTarget(this)) }

  ExternalIdentifiers getExternalIdentifierTarget() { result = getExternalIdentifierTarget(this) }
}

predicate isReferencedInTranslationUnit(
  ExternalIdentifiers e, ExternalIdentifierReference r, TranslationUnit t
) {
  r.getExternalIdentifierTarget() = e and
  r.getFile() = t
}

from ExternalIdentifiers e, ExternalIdentifierReference a1, TranslationUnit t1
where
  not isExcluded(e, Declarations6Package::shouldNotBeDefinedWithExternalLinkageQuery()) and
  isReferencedInTranslationUnit(e, a1, t1) and
  // Not referenced in any other translation unit
  not exists(TranslationUnit t2 |
    isReferencedInTranslationUnit(e, _, t2) and
    not t1 = t2
  )
select e, "Declaration with external linkage is accessed in only one translation unit $@.", a1,
  a1.toString()
