/**
 * @id cpp/autosar/copy-operator-shall-only-copy-object
 * @name A6-2-1: Copy operator shall only copy the object of the class type
 * @description Copy operator shall copy base classes and data members of a class without any side
 *              effects.
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
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.sideeffect.Customizations
import codingstandards.cpp.Operator

class ModifyClassObjectMember extends GlobalSideEffect::Range {
  ModifyClassObjectMember() { exists(MemberFunction f | this = getAMemberVariableEffect(f)) }
}

class TargetUserCopyOperator extends UserCopyOperator, SideEffectTargetFunction { }

from
  TargetUserCopyOperator op, NonLocalSideEffect e, SideEffectFlowNode src, SideEffectFlowNode dest
where
  not isExcluded(op, SideEffects2Package::copyOperatorShallOnlyCopyObjectQuery()) and
  e = getASideEffectInFunction(op) and
  not e instanceof CopyOperatorFieldCopyAssign and
  src.asSideEffect() = e and
  dest.asFunction() = op
select op, src, dest, "The copy operator of the class $@ has unrelated $@.", op.getDeclaringType(),
  op.getDeclaringType().getName(), e, "side effect"
