/**
 * @id cpp/autosar/move-constructor-shall-only-move-object
 * @name A12-8-1: Move constructor shall only move the object of the class type
 * @description Move constructor shall move data members of a class without any side effects.
 * @kind path-problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a12-8-1
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
import codingstandards.cpp.Constructor

class ModifyClassObjectMember extends GlobalSideEffect::Range {
  ModifyClassObjectMember() { exists(MemberFunction f | this = getAMemberVariableEffect(f)) }
}

class TargetMoveConstructor extends MoveConstructor, SideEffectTargetFunction { }

from MoveConstructor mc, NonLocalSideEffect e, SideEffectFlowNode src, SideEffectFlowNode dest
where
  not isExcluded(mc, SideEffects2Package::moveConstructorShallOnlyMoveObjectQuery()) and
  e = getASideEffectInFunction(mc) and
  not e instanceof MoveConstructorFieldCopyInit and
  not e instanceof MoveConstructorFieldCopyAssign and
  not e instanceof MoveConstructorFieldReset and
  src.asSideEffect() = e and
  dest.asFunction() = mc
select mc, src, dest, "The move constructor of the class $@ has unrelated $@.",
  mc.getDeclaringType(), mc.getDeclaringType().getName(), e, "side effect"
