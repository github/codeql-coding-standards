/**
 * @id cpp/autosar/unused-local-variable
 * @name M0-1-3: A project shall not contain unused local variables
 * @description Unused variables complicate the program and can indicate a possible mistake on the
 *              part of the programmer.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m0-1-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.deadcode.UnusedVariables

// Collect constant values that we should use to exclude otherwise unused constexpr variables.
//
// For constexpr variables used as template arguments or in static_asserts, we don't see accesses
// (just the appropriate literals). We therefore take a conservative approach and do not report
// constexpr variables whose values are used in such contexts.
//
// For performance reasons, these special values should be collected in a single pass.
predicate excludedConstantValue(string value) {
  value = any(ClassTemplateInstantiation cti).getTemplateArgument(_).(Expr).getValue()
  or
  value = any(StaticAssert sa).getCondition().getAChild*().getValue()
}

/**
 * Defines the local variables that should be excluded from the unused variable analysis based
 * on their constant value.
 *
 * See `excludedConstantValue` for more details.
 */
predicate excludeVariableByValue(Variable variable) {
  variable.isConstexpr() and
  excludedConstantValue(getConstExprValue(variable))
}

// TODO: This predicate may be possible to merge with M0-1-4's getUseCount(). These two rules
// diverged to handle `excludeVariableByValue`, but may be possible to merge.
int getUseCountConservatively(Variable v) {
  result =
    count(VariableAccess access | access = v.getAnAccess()) +
      count(UserProvidedConstructorFieldInit cfi | cfi.getTarget() = v) +
      // In case an array type uses a constant in the same scope as the constexpr variable,
      // consider it as used.
      countUsesInLocalArraySize(v)
}

predicate isConservativelyUnused(Variable v) {
  getUseCountConservatively(v) = 0 and
  not excludeVariableByValue(v)
}

from PotentiallyUnusedLocalVariable v
where
  not isExcluded(v, DeadCodePackage::unusedLocalVariableQuery()) and
  // Local variable is never accessed
  not exists(v.getAnAccess()) and
  // Sometimes multiple objects representing the same entities are created in
  // the AST. Check if those are not accessed as well. Refer issue #658
  not exists(LocalScopeVariable another |
    another.getDefinitionLocation() = v.getDefinitionLocation() and
    another.hasName(v.getName()) and
    exists(another.getAnAccess()) and
    another != v
  ) and
  isConservativelyUnused(v)
select v, "Local variable '" + v.getName() + "' in '" + v.getFunction().getName() + "' is not used."
