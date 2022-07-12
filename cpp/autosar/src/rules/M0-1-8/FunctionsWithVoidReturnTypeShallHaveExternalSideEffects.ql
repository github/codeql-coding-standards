/**
 * @id cpp/autosar/functions-with-void-return-type-shall-have-external-side-effects
 * @name M0-1-8: All functions with void return type shall have external side effect(s)
 * @description All functions with void return type are expected to contribute to the generation of
 *              outputs and should therefore exhibit an external side effect.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/autosar/id/m0-1-8
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.sideeffect.Customizations
import codingstandards.cpp.exceptions.ExceptionFlow

class ThrownExceptionNotCaughtInSameFunction extends GlobalSideEffect::Range {
  ThrownExceptionNotCaughtInSameFunction() {
    this instanceof ThrowingExpr and
    not exists(CatchBlock cb |
      isCaught(cb, this.(ThrowingExpr).getAnExceptionType()) and
      cb.getEnclosingFunction() = this.getEnclosingFunction()
    )
  }
}

class ExternalCall extends ExternalSideEffect::Range, Call {
  ExternalCall() {
    exists(Function f | this.getTarget() = f |
      not f.hasDefinition() and not f.isCompilerGenerated()
    )
  }
}

class UnresolvedCall extends ExternalSideEffect::Range, Call {
  UnresolvedCall() { not exists(this.getTarget()) }
}

from Function f
where
  not isExcluded(f,
    SideEffects2Package::functionsWithVoidReturnTypeShallHaveExternalSideEffectsQuery()) and
  f.getType() instanceof VoidType and
  not f instanceof MemberFunction and
  exists(f.getBlock()) and
  not hasExternalOrGlobalSideEffectInFunction(f) and
  not exists(AliasParameter p | p = f.getAParameter() | p.isModified())
select f, "The function $@ with return type void does not have any external side effects.", f,
  f.getName()
