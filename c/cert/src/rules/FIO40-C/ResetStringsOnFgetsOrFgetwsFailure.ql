/**
 * @id c/cert/reset-strings-on-fgets-or-fgetws-failure
 * @name FIO40-C: Reset strings on fgets() or fgetws() failure
 * @description A string that used in a failing call to fgets() or fgetws() requires a reset before
 *              being referenced.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/fio40-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.FgetsErrorManagement
import codingstandards.cpp.Dereferenced
import codingstandards.c.cert

/*
 * Models calls to `memcpy` `strcpy` `strncpy` and their wrappers
 */

class MemcpyLikeCall extends FunctionCall {
  Expr destination;

  MemcpyLikeCall() {
    exists(string names |
      names = ["memcpy", "memcpy_s", "strcpy", "strcpy_s", "strncpy", "strncpy_s"] and
      (
        this.getTarget().hasGlobalName(names)
        or
        exists(MacroInvocation mi | mi.getMacroName() = names and this = mi.getExpr())
      ) and
      (
        destination = this.getArgument(0)
        or
        exists(MemcpyLikeCall internalCall, int destination_pos |
          internalCall.getEnclosingFunction() = this.getTarget() and
          // Map destination argument
          destination = this.getArgument(destination_pos) and
          DataFlow::localFlow(DataFlow::parameterNode(this.getTarget().getParameter(destination_pos)),
            DataFlow::exprNode(internalCall.getDestination()))
        )
      )
    )
  }

  Expr getDestination() { result = destination }
}

/*
 * Models accesses to the buffer by dereferencing the associated expression
 */

class BuffAccessExpr extends Expr {
  BuffAccessExpr() {
    // dereferenced expressions
    this instanceof DereferencedExpr
    or
    // any parameter to a function
    this = any(FunctionCall fc).getAnArgument()
  }
}

/*
 * Models buffer reset by means of overwriting
 */

class BuffReset extends Expr {
  BuffReset() {
    // *buf = ''
    this = any(Assignment a).getLValue().(PointerDereferenceExpr).getOperand()
    or
    // buf[0] = ''
    this = any(Assignment a).getLValue().(ArrayExpr).getArrayBase()
    or
    // FgetsLikeCall
    this = any(FgetsLikeCall fgets).getBuffer()
    or
    // MemcpyLikeCall
    this = any(MemcpyLikeCall a).getDestination()
  }
}

/*
 * CFG nodes that follows a failing call to `fgets`
 */

ControlFlowNode followsNullFgets(FgetsLikeCall fgets) {
  exists(FgetsGuard guard |
    fgets = guard.getFgetCall() and
    //Stop recursion on buffer reset
    not exists(Variable v |
      v.getAnAccess() = fgets.getBuffer() and v.getAnAccess() = result.(BuffReset)
    ) and
    (
      result = guard.getNullSuccessor()
      or
      result = followsNullFgets(fgets).getASuccessor()
    )
  )
}

from BuffAccessExpr e, FgetsLikeCall fgets
where
  not isExcluded(e, IO2Package::resetStringsOnFgetsOrFgetwsFailureQuery()) and
  e = followsNullFgets(fgets) and
  exists(Variable v | v.getAnAccess() = fgets.getBuffer() and v.getAnAccess() = e)
select e, "The buffer is not reset before being referenced following a failed $@.", fgets,
  fgets.toString()
