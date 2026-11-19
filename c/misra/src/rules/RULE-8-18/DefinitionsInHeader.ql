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
 * Gets the outermost macro invocation that expands `element`, if any, such as
 * `DEFINE_OBJECT(0, x)` for `x` in `#define DEFINE_OBJECT(value, name) int name = value`.
 */
MacroInvocation getOutermostMacroInvocation(Locatable element) {
  element = result.getAnExpandedElement() and
  not exists(result.getParentInvocation())
}

/**
 * Holds if `invocation` is an outermost macro invocation that expands `entry` together with at
 * least part of `initializer`, such as in `#define DEFINE_OBJECT(value, name) int name = value`.
 */
predicate hasMacroInitializer(
  VariableDeclarationEntry entry, MacroInvocation invocation, Initializer initializer
) {
  entry.isDefinition() and
  initializer = entry.getVariable().getInitializer() and
  invocation = getOutermostMacroInvocation(entry) and
  invocation = getOutermostMacroInvocation(initializer.getExpr().getAChild*())
}

/**
 * Holds if `initializer` follows `entry` in source order in every macro expansion at
 * `initializer`'s location without an intervening definition of the same variable, such as in
 * `int global_object = 1;`.
 */
predicate hasSourceOrderInitializer(VariableDeclarationEntry entry, Initializer initializer) {
  entry.isDefinition() and
  initializer = entry.getVariable().getInitializer() and
  not hasMacroInitializer(_, _, initializer) and
  entry.getLocation().isBefore(initializer.getLocation(), _) and
  not exists(VariableDeclarationEntry later |
    later.getVariable() = entry.getVariable() and
    later.isDefinition() and
    entry.getLocation().isBefore(later.getLocation(), _) and
    later.getLocation().isBefore(initializer.getLocation(), _)
  ) and
  not exists(MacroInvocation initMacro, MacroInvocation otherMacro |
    initMacro = getOutermostMacroInvocation(initializer.getExpr()) and
    otherMacro.getLocation() = initMacro.getLocation() and
    not exists(otherMacro.getParentInvocation()) and
    not exists(Initializer otherInitializer |
      otherInitializer = entry.getVariable().getInitializer() and
      otherMacro = getOutermostMacroInvocation(otherInitializer.getExpr())
    )
  )
}

/**
 * A variable declaration entry that defines and initializes a variable in every expansion, for
 * example:
 * ```c
 * int global_object = 1;
 * ```
 */
class InitializedDefinition extends VariableDeclarationEntry {
  InitializedDefinition() {
    hasSourceOrderInitializer(this, _)
    or
    forex(MacroInvocation invocation | invocation = getOutermostMacroInvocation(this) |
      hasMacroInitializer(this, invocation, _)
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
