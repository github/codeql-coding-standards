/**
 * @id c/misra/external-object-or-function-not-declared-in-one-file
 * @name RULE-8-5: An external object or function shall be declared once in one and only one file
 * @description Declarations in multiple files can lead to unexpected program behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-8-5
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from DeclarationEntry de, DeclarationEntry otherDeclaration, string kind
where
  not isExcluded(de, Declarations5Package::externalObjectOrFunctionNotDeclaredInOneFileQuery()) and
  //this rule applies to non-defining declarations only
  not de.isDefinition() and
  not otherDeclaration.isDefinition() and
  exists(Declaration d |
    de.getDeclaration() = d and
    otherDeclaration.getDeclaration() = d and
    de.getFile() != otherDeclaration.getFile()
  ) and
  (
    de.getDeclaration() instanceof Function and kind = "function"
    or
    de.getDeclaration() instanceof Variable and
    not de.getDeclaration() instanceof Parameter and
    kind = "variable"
  ) and
  // Apply an ordering based on location to enforce that (de1, de2) = (de2, de1) and we only report (de1, de2).
  de.getFile().getAbsolutePath() < otherDeclaration.getFile().getAbsolutePath()
select de,
  "The " + kind + " declaration " + de.getName() +
    " is declared in multiple files and has an additional $@.", otherDeclaration, "declaration"
