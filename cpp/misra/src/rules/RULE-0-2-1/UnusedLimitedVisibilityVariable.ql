/**
 * @id cpp/misra/unused-limited-visibility-variable
 * @name RULE-0-2-1: Variables with limited visibility should be used at least once
 * @description Variables that do not affect the runtime of a program indicate potential errors and
 *              interfere with code readability.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-0-2-1
 *       scope/single-translation-unit
 *       correctness
 *       readability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.deadcode.UnusedVariables
import codingstandards.cpp.Linkage

class UnusedVariable extends Variable {
  string description;

  UnusedVariable() {
    not hasExternalLinkage(this) and
    not hasAttrUnused(this) and
    (
      this instanceof FullyUnusedGlobalOrNamespaceVariable and
      description = "Variable '" + this.getQualifiedName() + "' is unused."
      or
      this instanceof FullyUnusedLocalVariable and
      description = "Variable '" + this.getName() + "' is unused."
      or
      this instanceof FullyUnusedMemberVariable and
      description = "Member variable '" + this.getName() + "' is unused."
    ) and
    not (isConstant(this) and this.getFile() instanceof HeaderFile and hasNamespaceScope(this))
  }

  string getProblemDescription() { result = description }
}

predicate isConstant(Variable v) { v.isConst() or v.isConstexpr() or v.isConstinit() }

from UnusedVariable var
where not isExcluded(var, DeadCode7Package::unusedLimitedVisibilityVariableQuery())
select var, var.getProblemDescription()
