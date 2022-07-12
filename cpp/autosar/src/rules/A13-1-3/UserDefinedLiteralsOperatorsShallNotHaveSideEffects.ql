/**
 * @id cpp/autosar/user-defined-literals-operators-shall-not-have-side-effects
 * @name A13-1-3: User defined literals operators shall not perform side effects
 * @description User defined literals operators with side effects can exhibit unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a13-1-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.UserDefinedLiteral
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

from UserDefinedLiteral udl, SideEffect e
where
  not isExcluded(udl,
    SideEffects2Package::userDefinedLiteralsOperatorsShallNotHaveSideEffectsQuery()) and
  e = getAnExternalOrAGlobalSideEffectInFunction(udl) and
  // Exclude constructor field initializations part of the conversion to the target type.
  not exists(ConstructorFieldInit cfi | cfi = e |
    cfi.getEnclosingFunction().getDeclaringType() = udl.getType()
  )
select udl,
  "User defined literal operator should only perform conversion of passed parameters, but has $@.",
  e, "side effect"
