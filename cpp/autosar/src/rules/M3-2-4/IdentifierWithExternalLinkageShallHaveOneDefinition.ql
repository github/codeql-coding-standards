/**
 * @id cpp/autosar/identifier-with-external-linkage-shall-have-one-definition
 * @name M3-2-4: An identifier with external linkage shall have exactly one definition
 * @description An identifier with multiple definitions in different translation units leads to
 *              undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/m3-2-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Linkage

from Declaration d, DeclarationEntry de1, DeclarationEntry de2
where
  not isExcluded(d) and
  not isExcluded([de1, de2]) and
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
  )
select de1, "The identifier " + de1.getName() + " has external linkage and is redefined $@.", de2,
  "here"
