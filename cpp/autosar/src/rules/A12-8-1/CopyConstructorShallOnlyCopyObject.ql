/**
 * @id cpp/autosar/copy-constructor-shall-only-copy-object
 * @name A12-8-1: Copy constructor shall only copy the object of the class type
 * @description Copy constructor shall copy base classes and data members of a class without any
 *              side effects.
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
import codingstandards.cpp.sideeffect.DefaultEffects
import codingstandards.cpp.Constructor
import codingstandards.cpp.Operator

class ModifyClassObjectMember extends GlobalSideEffect::Range {
  ModifyClassObjectMember() {
    exists(MemberFunction f |
      this = getAMemberVariableEffect(f) and
      not this.getEnclosingFunction() instanceof CopyOperator
    )
  }
}

class TargetCopyConstructor extends CopyConstructor, SideEffectTargetFunction { }

/** Holds if `callee` is reachable through a compiler generated call from `caller` or a function reachable by `caller`. */
predicate reachableThroughCompilerGeneratedCall(Function caller, Function callee) {
  exists(Call c |
    c.getEnclosingFunction() = caller and c.getTarget() = callee and c.isCompilerGenerated()
  )
  or
  exists(Function mid, Call c |
    c.getTarget() = mid and
    c.getEnclosingFunction() = caller and
    reachableThroughCompilerGeneratedCall(mid, callee)
  )
}

from TargetCopyConstructor cc, NonLocalSideEffect e, SideEffectFlowNode src, SideEffectFlowNode dest
where
  not isExcluded(cc, SideEffects2Package::copyConstructorShallOnlyCopyObjectQuery()) and
  e = getASideEffectInFunction(cc) and
  not e instanceof CopyConstructorFieldCopyInit and
  not e instanceof CopyConstructorFieldCopyAssign and
  not exists(Constructor c |
    reachableThroughCompilerGeneratedCall(cc, c) and
    c.calls*(e.getEnclosingFunction()) and
    (e instanceof MemberAssignExpr or e instanceof ConstructorInit)
  ) and
  src.asSideEffect() = e and
  dest.asFunction() = cc
select cc, src, dest, "The copy constructor of the class $@ has unrelated $@.",
  cc.getDeclaringType(), cc.getDeclaringType().getName(), e, "side effect"
