/**
 * @id cpp/misra/local-variable-static-storage-duration
 * @name RULE-6-7-1: Local variables shall not have static storage duration
 * @description Local variables that have static storage duration can be harder to reason about and
 *              can lead to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-7-1
 *       correctness
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.lifetimes.CppObjects

from VariableObjectIdentity v
where
  not isExcluded(v, Declarations2Package::localVariableStaticStorageDurationQuery()) and
  v.getStorageDuration().isStatic() and
  v instanceof LocalVariable and
  not v.(Variable).isConst() and
  not v.(Variable).isConstexpr()
select v, "Local variable with static storage duration."
