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

/**
 * Re-introduce function calls into access description as
 * "any reference"
 */
class Reference extends NameQualifiableElement {
  Reference() {
    this instanceof Access or
    this instanceof FunctionCall
  }
}

from ExternalIdentifiers e, Reference a1, TranslationUnit t1
where
  not isExcluded(e, Declarations6Package::shouldNotBeDefinedWithExternalLinkageQuery()) and
  (a1.(Access).getTarget() = e or a1.(FunctionCall).getTarget() = e) and
  a1.getFile() = t1 and
  //not accessed in any other translation unit
  not exists(TranslationUnit t2, Reference a2 |
    not t1 = t2 and
    (a2.(Access).getTarget() = e or a2.(FunctionCall).getTarget() = e) and
    a2.getFile() = t2
  )
select e, "Declaration with external linkage is accessed in only one translation unit $@.", a1,
  a1.toString()
