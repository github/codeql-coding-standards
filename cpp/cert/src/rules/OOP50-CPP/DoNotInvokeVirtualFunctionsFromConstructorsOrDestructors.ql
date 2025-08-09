/**
 * @id cpp/cert/do-not-invoke-virtual-functions-from-constructors-or-destructors
 * @name OOP50-CPP: Do not invoke virtual functions from constructors or destructors
 * @description Invocation of virtual functions may result in undefined behavior during object
 *              construction or destruction.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/oop50-cpp
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

predicate thisCall(FunctionCall c) {
  c.getQualifier() instanceof ThisExpr or
  c.getQualifier().(PointerDereferenceExpr).getChild(0) instanceof ThisExpr
}

predicate nonVirtualMember(MemberFunction mf, Class c) {
  mf = c.getAMemberFunction() and
  not mf instanceof Constructor and
  not mf instanceof Destructor and
  not mf.isVirtual()
}

/**
 * Holds if a given FunctionCall uses ThisExpr (implicitly or explicitly)
 * and calls a virtual member function, and the specified overriding
 * function exists as a possible virtual call target
 */
predicate virtualThisCall(FunctionCall c, Function overridingFunction) {
  c.isVirtual() and
  thisCall(c) and
  overridingFunction = c.getTarget().(VirtualFunction).getAnOverridingFunction()
}

/**
 * Holds if a function call from 'source' to 'target' exists and is a 'thisCall'
 * If 'c' is specified, limits 'source' and 'target' to members of 'c'.
 */
predicate callFromNonVirtual(MemberFunction source, Class c, MemberFunction target) {
  exists(FunctionCall fc |
    fc.getEnclosingFunction() = source and fc.getTarget() = target and thisCall(fc)
  ) and
  target = c.getAMemberFunction() and
  nonVirtualMember(source, c)
}

/**
 * Holds if 'caller' or a member function called with a thisCall by 'caller' calls 'target'
 * If 'c' is specified, limits 'caller' and 'target' to members of 'c'.
 */
predicate indirectlyCallsVirtualFunction(MemberFunction caller, Function target, Class c) {
  exists(FunctionCall fc |
    virtualThisCall(fc, _) and
    fc.getEnclosingFunction() = caller and
    fc.getTarget() = target and
    nonVirtualMember(caller, c)
  )
  or
  exists(MemberFunction mid |
    indirectlyCallsVirtualFunction(mid, target, c) and
    callFromNonVirtual(caller, c, mid)
  )
}

from FunctionCall call, string explanation, Function virtFunction, Function overridingFunction
where
  not isExcluded(virtFunction,
    InheritancePackage::doNotInvokeVirtualFunctionsFromConstructorsOrDestructorsQuery()) and
  (
    // for calls within a constructor or destructor
    call.getEnclosingFunction() instanceof Constructor or
    call.getEnclosingFunction() instanceof Destructor
  ) and
  (
    (
      // where the call is to a virtual function using an explicit or implicit ThisExpr
      virtualThisCall(call, overridingFunction) and
      explanation = "Call to virtual function $@ which is overridden in $@."
    ) and
    // and the virtual callee is a member of a derived type of the caller's enclosing type
    virtFunction = call.getTarget() and
    overridingFunction.getDeclaringType().getABaseClass+() =
      call.getEnclosingFunction().getDeclaringType()
    or
    // or recurse all ThisExpr non-virtual calls to methods until a call to a virtual function
    exists(VirtualFunction target |
      thisCall(call) and indirectlyCallsVirtualFunction(call.getTarget(), target, _)
    |
      explanation =
        "Call to function " + call.getTarget().getName() +
          " that calls virtual function $@ (overridden in $@)." and
      virtFunction = target and
      overridingFunction = target.getAnOverridingFunction() and
      overridingFunction.getDeclaringType().getABaseClass+() =
        call.getEnclosingFunction().getDeclaringType()
    )
  )
select call, explanation, virtFunction, virtFunction.getName(), overridingFunction,
  overridingFunction.getDeclaringType().getName()
