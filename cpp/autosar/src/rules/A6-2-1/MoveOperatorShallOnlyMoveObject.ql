/**
 * @id cpp/autosar/move-operator-shall-only-move-object
 * @name A6-2-1: Move operator shall only move the object of the class type
 * @description Move operator shall move data members of a class without any side effects.
 * @kind path-problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a6-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SideEffect
import codingstandards.cpp.SideEffect::PathGraph
import codingstandards.cpp.sideeffect.Customizations
import codingstandards.cpp.Operator

class ModifyClassObjectMember extends GlobalSideEffect::Range {
  ModifyClassObjectMember() { exists(MemberFunction f | this = getAMemberVariableEffect(f)) }
}

class TargetUserMoveOperator extends UserMoveOperator, SideEffectTargetFunction { }

from
  TargetUserMoveOperator op, NonLocalSideEffect e, SideEffectFlowNode src, SideEffectFlowNode dest
where
  not isExcluded(op, SideEffects2Package::moveOperatorShallOnlyMoveObjectQuery()) and
  e = getASideEffectInFunction(op) and
  not e instanceof MoveOperatorFieldCopyAssign and
  not e instanceof MoveOperatorFieldReset and
  src.asSideEffect() = e and
  dest.asFunction() = op
select op, src, dest, "The move operator of the class $@ has unrelated $@.", op.getDeclaringType(),
  op.getDeclaringType().getName(), e, "side effect"
