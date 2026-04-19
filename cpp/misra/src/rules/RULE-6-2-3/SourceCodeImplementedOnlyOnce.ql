/**
 * @id cpp/misra/source-code-implemented-only-once
 * @name RULE-6-2-3: The source code used to implement an entity shall appear only once
 * @description Implementing an entity in multiple source locations violates the one-definition rule
 *              and leads to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-2-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

predicate isInline(DeclarationEntry d) {
  // There is no way to detect if a `GlobalVariable` is declared inline.
  d.getDeclaration().(Function).isInline()
}

from DeclarationEntry d1, DeclarationEntry d2, string namespace, string name
where
  not isExcluded([d1, d2], Declarations8Package::sourceCodeImplementedOnlyOnceQuery()) and
  d1 != d2 and
  d1.isDefinition() and
  d2.isDefinition() and
  isInline(d1) and
  isInline(d2) and
  d1.getDeclaration().hasQualifiedName(namespace, name) and
  d2.getDeclaration().hasQualifiedName(namespace, name) and
  d1.getFile() != d2.getFile() and
  d1.getFile().getAbsolutePath() < d2.getFile().getAbsolutePath()
select d1,
  "Inline variable '" + d1.getName() +
    "' is defined in multiple files, violating the source code uniqueness requirement."
