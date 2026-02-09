/**
 * @id cpp/cert/do-not-rely-on-side-effects-in-decl-val-expression
 * @name EXP52-CPP: Do not rely on side effects in the operator declval
 * @description The declval operator does not evaluate expressions so reliance on side effects will
 *              result in unexpected behavior.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/cert/id/exp52-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p3
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Sfinae
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

class DeclValCall extends FunctionCall {
  DeclValCall() { this.getTarget().hasQualifiedName("std", "declval") }
}

from Expr e
where
  not isExcluded(e, SideEffects1Package::doNotRelyOnSideEffectsInDeclValExpressionQuery()) and
  exists(DeclValCall call | e.getAChild() = call) and
  hasSideEffect(e) and
  not e.isInMacroExpansion() and
  not isInSFINAEContext(e)
select e, "Relying on side effects in the declval expression may result in unexpected behavior."
