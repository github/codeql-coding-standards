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

predicate excludedConstantValue(string value) {
  // For constexpr variables used as template arguments, we don't see accesses (just the
  // appropriate literals). We therefore take a conservative approach and count the number of
  // template instantiations that use the given constant, and consider each one to be a use
  // of the variable
  value = any(ClassTemplateInstantiation cti).getTemplateArgument(_).(Expr).getValue()
  or
  // For static asserts too, check if there is a child which has the same value
  // as the constexpr variable.
  value = any(StaticAssert sa).getCondition().getAChild*().getValue()
}

pragma[inline_late]
bindingset[variable]
predicate excludeVariableByValue(Variable variable) {
  variable.isConstexpr() and
  excludedConstantValue(getConstExprValue(variable))
}

// This predicate is similar to getUseCount for M0-1-4 except that it also
// considers static_asserts. This was created to cater for M0-1-3 specifically
// and hence, doesn't attempt to reuse the M0-1-4 specific predicate
// - getUseCount()
int getUseCountConservatively(Variable v) {
  result =
    count(VariableAccess access | access = v.getAnAccess()) +
      count(UserProvidedConstructorFieldInit cfi | cfi.getTarget() = v) +
      //count(ClassTemplateInstantiation cti |
      //  cti.getTemplateArgument(_).(Expr).getValue() = getConstExprValue(v)
      //) +
      // In case an array type uses a constant in the same scope as the constexpr variable,
      // consider it as used.
      countUsesInLocalArraySize(v)
}

predicate isConservativelyUnused(Variable v) {
  getUseCountConservatively(v) = 0
  and
  not excludeVariableByValue(v)
}

pragma[inline_late]
bindingset[v]
predicate mayAppearInStaticAssert(Variable v) {
  // For static asserts too, check if there is a child which has the same value
  // as the constexpr variable.
  v.isConstexpr() and
  exists(StaticAssert sa |
    sa.getCondition().getAChild*().getValue() = getConstExprValue(v)
  )
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
