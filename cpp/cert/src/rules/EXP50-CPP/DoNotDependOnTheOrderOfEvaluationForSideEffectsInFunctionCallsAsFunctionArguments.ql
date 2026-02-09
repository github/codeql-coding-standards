/**
 * @id cpp/cert/do-not-depend-on-the-order-of-evaluation-for-side-effects-in-function-calls-as-function-arguments
 * @name EXP50-CPP: Do not depend on the order of evaluation of function calls as function arguments for side effects
 * @description Depending on the order of evaluation for side effects in function calls that are
 *              function arguments can result in unexpected program behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/exp50-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p8
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.SideEffect
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

/** Holds if the function's return value is derived from the `AliasParamter` p. */
predicate returnValueDependsOnAliasParameter(AliasParameter p) {
  exists(ReturnStmt ret | ret = p.getFunction().getBlock().getAStmt() |
    TaintTracking::localTaint(DataFlow::parameterNode(p), DataFlow::exprNode(ret.getExpr()))
    or
    exists(FieldAccess fa, VariableAccess va | fa.getQualifier() = va and va.getTarget() = p |
      TaintTracking::localTaint(DataFlow::exprNode(fa), DataFlow::exprNode(ret.getExpr()))
    )
    or
    exists(FunctionCall call, VariableAccess va | call.getQualifier() = va and va.getTarget() = p |
      TaintTracking::localTaint(DataFlow::exprNode(call), DataFlow::exprNode(ret.getExpr()))
    )
    or
    exists(VariableAccess va | va.getTarget() = p | ret.getAChild+() = va)
  )
  or
  exists(FunctionCall call, ReturnStmt ret, int i, AliasParameter q |
    ret = p.getFunction().getBlock().getAStmt() and call.getEnclosingFunction() = p.getFunction()
  |
    DataFlow::localFlow(DataFlow::parameterNode(p), DataFlow::exprNode(call.getArgument(i))) and
    q = call.getTarget().getParameter(i) and
    returnValueDependsOnAliasParameter(q) and
    TaintTracking::localTaint(DataFlow::exprNode(call), DataFlow::exprNode(ret.getExpr()))
  )
}

/** Holds if the function `f`'s return value is derived from the global variable `v`. */
predicate returnValueDependsOnGlobalVariable(Function f, GlobalVariable v) {
  exists(ReturnStmt ret, VariableAccess va |
    ret = f.getBlock().getAStmt() and va.getTarget() = v and va.getEnclosingFunction() = f
  |
    TaintTracking::localTaint(DataFlow::exprNode(va), DataFlow::exprNode(ret.getExpr()))
  )
  or
  exists(ReturnStmt ret, FunctionCall call |
    ret = f.getBlock().getAStmt() and
    call.getEnclosingFunction() = f and
    returnValueDependsOnGlobalVariable(call.getTarget(), v) and
    TaintTracking::localTaint(DataFlow::exprNode(call), DataFlow::exprNode(ret.getExpr()))
  )
}

/** Holds if the member function `f`'s return value is derived from the member variable `v`. */
predicate returnValueDependsOnMemberVariable(MemberFunction f, MemberVariable v) {
  exists(ReturnStmt ret, VariableAccess va |
    ret = f.getBlock().getAStmt() and
    va.getTarget() = v and
    va.getEnclosingFunction() = f and
    v.getDeclaringType() = f.getDeclaringType()
  |
    TaintTracking::localTaint(DataFlow::exprNode(va), DataFlow::exprNode(ret.getExpr()))
  )
}

from
  FunctionCall call, Function f1, Function f2, int i, int j, FunctionCall arg1, FunctionCall arg2,
  Variable v1, Variable v2
where
  not isExcluded(call,
    SideEffects1Package::doNotDependOnTheOrderOfEvaluationForSideEffectsInFunctionCallsAsFunctionArgumentsQuery()) and
  arg1 = call.getArgument(i) and
  arg2 = call.getArgument(j) and
  i < j and
  arg1.getTarget() = f1 and
  arg2.getTarget() = f2 and
  (
    // Considering the shared states:
    // - pointer or reference arguments being used in both functions
    exists(AliasParameter p1, AliasParameter p2 |
      v1 = p1 and
      v2 = p2 and
      f1.getAParameter() = p1 and
      f2.getAParameter() = p2 and
      p1.isModified() and
      p2.isModified() and
      globalValueNumber(arg1.getArgument(p1.getIndex())) =
        globalValueNumber(arg2.getArgument(p2.getIndex())) and
      returnValueDependsOnAliasParameter(p1) and
      returnValueDependsOnAliasParameter(p2)
    )
    or
    // - global variables being used in both functions
    exists(GlobalVariable v, VariableEffect ve1, VariableEffect ve2 |
      v1 = v and
      v2 = v and
      returnValueDependsOnGlobalVariable(f1, v) and
      returnValueDependsOnGlobalVariable(f2, v) and
      ve1.getTarget() = v and
      ve2.getTarget() = v
    )
    or
    // - member variables that can be modified in both functions
    exists(MemberVariable v |
      v1 = v and
      v2 = v and
      returnValueDependsOnMemberVariable(f1, v) and
      returnValueDependsOnMemberVariable(f2, v) and
      v = getAMemberVariableEffect(f1).getTarget() and
      v = getAMemberVariableEffect(f2).getTarget() and
      (
        globalValueNumber(arg1.getQualifier()) = globalValueNumber(arg2.getQualifier())
        or
        v.isStatic() and arg1.getQualifier().getType() = arg2.getQualifier().getType()
      )
    )
  )
select call,
  "Depending on the order of evaluation for the arguments $@ and $@ for side effects on shared state is unspecified and can result in unexpected behavior.",
  arg1, arg1.toString(), arg2, arg2.toString()
