/**
 * @id c/misra/definitions-in-header
 * @name RULE-8-18: There shall be no tentative definitions in a header file
 * @description Tentative definitions in headers can introduce unintended definitions in multiple
 *              translation units.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-8-18
 *       correctness
 *       external/misra/c/2025
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from VariableDeclarationEntry declaration, GlobalVariable variable
where
  not isExcluded(declaration, Declarations5Package::definitionsInHeaderQuery()) and
  declaration.getVariable() = variable and
  not declaration.hasSpecifier("extern") and
  not (declaration.isDefinition() and exists(variable.getInitializer())) and
  exists(Include include | include.getIncludedFile() = declaration.getFile())
select declaration,
  "Tentative definition of '" + declaration.getName() + "' appears in a header file."
