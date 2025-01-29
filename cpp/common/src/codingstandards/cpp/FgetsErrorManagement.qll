/**
 * A module for reasoning about the error management in the standard functions
 * `fgets`, `fgets` and their wrappers.
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.Guards

/*
 * Models calls to fgets fgetws and their wrappers
 */

class FgetsLikeCall extends FunctionCall {
  Expr buffer;
  Expr stream;

  FgetsLikeCall() {
    this.getTarget().hasGlobalName(["fgets", "fgetws"]) and
    buffer = this.getArgument(0) and
    stream = this.getArgument(2)
    or
    exists(FgetsLikeCall internalCall, ReturnStmt retStmt, int buffer_pos, int stream_pos |
      internalCall.getEnclosingFunction() = this.getTarget() and
      retStmt.getEnclosingFunction() = this.getTarget() and
      // Map return value
      DataFlow::localExprFlow(internalCall, retStmt.getExpr()) and
      // Map buffer argument
      buffer = this.getArgument(buffer_pos) and
      DataFlow::localFlow(DataFlow::parameterNode(this.getTarget().getParameter(buffer_pos)),
        DataFlow::exprNode(internalCall.getBuffer())) and
      // Map stream argument
      stream = this.getArgument(stream_pos) and
      DataFlow::localFlow(DataFlow::parameterNode(this.getTarget().getParameter(stream_pos)),
        DataFlow::exprNode(internalCall.getStream()))
    )
  }

  Expr getBuffer() { result = buffer }

  Expr getStream() { result = stream }
}

/*
 * A simple boolean expression built on a fgets-like function call
 * The boolean expression can span multiple statments
 * (e.g. a = !x; b=!a;)
 */

class BooleanFgetsExpr extends Expr {
  boolean isNull;
  boolean isNotNull;
  FgetsLikeCall fgetCall;
  Expr operand;

  BooleanFgetsExpr() {
    // if(fgets)
    fgetCall = this and
    isNull = false and
    isNotNull = true and
    operand = this
    or
    exists(BooleanFgetsExpr e |
      e != this and
      operand = e and
      fgetCall = e.getFgetCall() and
      (
        isNotNull = isNull.booleanNot() and
        (
          // if(e==0)
          e = this.(EQExpr).getAnOperand() and
          this.(EQExpr).getAnOperand() instanceof NullValue and
          isNull = e.isNull().booleanNot()
          or
          // if(e!=0)
          e = this.(NEExpr).getAnOperand() and
          this.(NEExpr).getAnOperand() instanceof NullValue and
          isNull = e.isNull()
          or
          // if(e)
          DataFlow::localExprFlow(e, this) and
          isNull = e.isNull()
          or
          // if(!e)
          e = this.(NotExpr).getOperand() and
          isNull = e.isNull().booleanNot()
          or
          // if(cond && e)
          e = this.(LogicalAndExpr).getRightOperand() and
          isNull = e.isNull()
          or
          // if(cond || e)
          e = this.(LogicalOrExpr).getRightOperand() and
          isNull = e.isNull()
        )
        or
        // if(e && cond)
        e = this.(LogicalAndExpr).getLeftOperand() and
        (
          isNull = false and
          isNotNull = false
        )
        or
        // if(e || cond)
        e = this.(LogicalOrExpr).getLeftOperand() and
        (
          isNull = true and
          isNotNull = true
        )
      )
    )
  }

  boolean isNull() { result = isNull }

  boolean isNotNull() { result = isNotNull }

  Expr getFgetCall() { result = fgetCall }

  Expr getOperand() { result = operand }
}

/*
 * A guard controlled by a `BooleanFgetsExpr`
 */

class FgetsGuard extends BooleanFgetsExpr {
  FgetsGuard() {
    exists(IfStmt i | i.getCondition() = this)
    or
    exists(Loop i | i.getCondition() = this)
  }

  Stmt getThenSuccessor() {
    exists(IfStmt i | i.getCondition() = this and result = i.getThen())
    or
    exists(Loop i | i.getCondition() = this and result = i.getStmt())
  }

  Stmt getElseSuccessor() {
    exists(IfStmt i |
      i.getCondition() = this and
      (
        i.hasElse() and result = i.getElse()
        or
        not i.hasElse() and result = i.getFollowingStmt()
      )
    )
    or
    exists(Loop i |
      i.getCondition() = this and
      result = i.getFollowingStmt()
    )
  }

  ControlFlowNode getNullSuccessor() {
    this.isNull() = true and result = this.getThenSuccessor()
    or
    this.isNull() = false and result = getElseSuccessor()
  }

  ControlFlowNode getNonNullSuccessor() {
    this.isNotNull() = true and
    result = this.getThenSuccessor()
    or
    this.isNotNull() = false and
    result = getElseSuccessor()
  }
}
