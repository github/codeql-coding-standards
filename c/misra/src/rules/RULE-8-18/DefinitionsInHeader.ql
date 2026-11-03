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

/**
 * An initialized definition of a variable, for example:
 * ```c
 * int global_object = 1;
 * ```
 */
class InitializedDefinition extends VariableDeclarationEntry {
  InitializedDefinition() {
    exists(Initializer initializer |
      this.isDefinition() and
      initializer = this.getVariable().getInitializer() and
      (
        initializer.getLocation().subsumes(this.getLocation())
        or
        // Initializers follow their own declarators, not definitions in other translation units.
        this.getLocation().isBefore(initializer.getLocation(), _) and
        not exists(VariableDeclarationEntry later |
          later.getVariable() = this.getVariable() and
          later.isDefinition() and
          this.getLocation().isBefore(later.getLocation(), _) and
          (
            later.getLocation().isBefore(initializer.getLocation(), _) or
            initializer.getLocation().subsumes(later.getLocation())
          )
        )
      )
    )
  }
}

/**
 * A tentative definition of a file-scope variable, for example:
 * ```c
 * int global_object;
 * static int internal_object;
 * ```
 */
class TentativeDefinition extends VariableDeclarationEntry {
  TentativeDefinition() {
    this.getVariable() instanceof GlobalVariable and
    not this.hasSpecifier("extern") and
    not this instanceof InitializedDefinition
  }
}

from TentativeDefinition definition
where
  not isExcluded(definition, Declarations5Package::definitionsInHeaderQuery()) and
  exists(Include include | include.getIncludedFile() = definition.getFile())
select definition,
  "Tentative definition of '" + definition.getName() + "' appears in a header file."
