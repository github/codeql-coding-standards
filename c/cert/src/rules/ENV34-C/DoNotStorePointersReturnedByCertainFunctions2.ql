/**
 * @id c/cert/do-not-store-pointers-returned-by-certain-functions
 * @name ENV34-C: Do not store pointers returned by certain functions
 * @description The value returned by functions `getenv`, `asctime`, `localeconv`, `setlocale`, and
 *              `strerror` may be overwritten by a second call.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/env34-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.controlflow.StackVariableReachability

class GetenvFunctionCall extends FunctionCall {
  GetenvFunctionCall() {
    this.getTarget().getName() = ["getenv", "asctime", "localeconv", "setlocale", "strerror"]
  }
}

predicate isGetenvReturnVar(ControlFlowNode node, StackVariable v) {
  exists(Expr expr | exprDefinition(v, node, expr) and expr instanceof GetenvFunctionCall)
}

class GetenvReachability extends StackVariableReachabilityExt {
  GetenvReachability() { this = "GetenvReachability" }

  override predicate isSource(ControlFlowNode node, StackVariable v) { isGetenvReturnVar(node, v) }

  override predicate isSink(ControlFlowNode node, StackVariable v) { isGetenvReturnVar(node, v) }

  override predicate isBarrier(
    ControlFlowNode source, ControlFlowNode node, ControlFlowNode next, StackVariable v
  ) {
    // any function call that may call getenv
    node instanceof FunctionCall
  }
}

string stdname(Function f) { result = f.getName() + f.getFile().getAbsolutePath() }

from ControlFlowNode c2, VariableAccess va
where
  not isExcluded(va, Contracts2Package::doNotStorePointersReturnedByCertainFunctionsQuery()) and
  exists(ControlFlowNode c1, Variable v1, Variable v2 |
    c1 != c2 and
    va.isRValue() and
    isGetenvReturnVar(c1, v1) and
    isGetenvReturnVar(c2, v2) and
    c2 = c1.getASuccessor+() and
    va = c2.getASuccessor+() and
    va = v1.getAnAccess() and
    //exclude variable redefinitions v1 = v2
    not exists(GetenvReachability r | r.reaches(c1, v1, c2))
  )
select va, "The string $@ may have been overwritten by the second $@.", va, va.toString(), c2,
  c2.toString()
