/**
 * @id cpp/autosar/constructor-error-leaves-object-in-invalid-state
 * @name A15-2-2: Constructors which fail initialization should deallocate the object's resources and throw an exception
 * @description If a constructor is not noexcept and the constructor cannot finish object
 *              initialization, then it shall deallocate the object's resources and it shall throw
 *              an exception.
 * @kind path-problem
 * @precision medium
 * @problem.severity error
 * @tags external/autosar/id/a15-2-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.ExceptionSpecifications
import ExceptionPathGraph

predicate functionMayThrow(Function f) {
  not f.isNoExcept() and
  not f.isNoThrow()
}

/** An expression which, directly or indirectly, calls `new`. */
class NewAllocationExpr extends OriginThrowingExpr {
  NewAllocationExpr() {
    this instanceof NewExpr and
    functionMayThrow(this.(NewExpr).getAllocator())
    or
    this.(FunctionCall).getTarget() instanceof NewWrapperFunction
  }

  override ExceptionType getAnExceptionType() { result instanceof StdBadAlloc }
}

/**
 * A function which "wraps" a call to a `NewWrapperExpr`, and returns the
 * result.
 */
class NewWrapperFunction extends Function {
  NewWrapperFunction() {
    exists(DataFlow::Node alloc | alloc.asExpr() instanceof NewAllocationExpr |
      exists(ReturnStmt rs | DataFlow::localFlow(alloc, DataFlow::exprNode(rs.getExpr()))) and
      alloc.getFunction() = this
    )
  }
}

/** An expression on which `delete` is called, directly or indirectly. */
class DeletedExpr extends Expr {
  DeletedExpr() {
    this = any(DeleteExpr deleteExpr).getExpr() or
    exists(DeleteWrapperFunction dwf, FunctionCall call |
      this = call.getArgument(dwf.getADeleteParameter().getIndex())
    )
  }
}

/**
 * A function which "wraps" a call to a `DeletedExpr`, and returns the result.
 */
class DeleteWrapperFunction extends Function {
  Parameter p;

  DeleteWrapperFunction() {
    DataFlow::localFlow(DataFlow::parameterNode(getAParameter()),
      DataFlow::exprNode(any(DeletedExpr dwe)))
  }

  Parameter getADeleteParameter() { result = p }
}

class ExceptionThrownInConstructor extends ExceptionThrowingExpr {
  Constructor c;

  ExceptionThrownInConstructor() { exists(getAFunctionThrownType(c, this)) }

  Constructor getConstructor() { result = c }
}

query predicate nodes(ExceptionFlowNode node) { any() }

from
  Constructor c, ExceptionThrownInConstructor throwingExpr, NewAllocationExpr newExpr,
  ExceptionFlowNode exceptionSource, ExceptionFlowNode functionNode
where
  not isExcluded(c, Exceptions2Package::constructorErrorLeavesObjectInInvalidStateQuery()) and
  not isNoExceptTrue(c) and
  // Constructor must exit with an exception
  c = throwingExpr.getConstructor() and
  throwingExpr.hasExceptionFlowReflexive(exceptionSource, functionNode, _) and
  exists(ExceptionFlowNode mid |
    edges*(exceptionSource, mid) and
    newExpr.getASuccessor+() = mid.asThrowingExpr() and
    edges*(mid, functionNode) and
    not exists(ExceptionFlowNode prior | edges(prior, mid) |
      prior.asCatchBlock().getEnclosingFunction() = c
    )
  ) and
  // New expression is in the constructor
  c = newExpr.getEnclosingFunction() and
  // Exception is thrown which directly leaves the function, and
  // occurs after the new expression Note: if an exception is caught
  // and re-thrown, this is the re-throw
  newExpr.getASuccessor+() = throwingExpr and
  // No delete of the new'd memory between allocation and
  // exception escape
  not exists(DeletedExpr deletedExpr |
    deletedExpr.getEnclosingFunction() = c and
    // Deletes the same memory location that was new'd
    DataFlow::localFlow(DataFlow::exprNode(newExpr), DataFlow::exprNode(deletedExpr)) and
    newExpr.getASuccessor+() = deletedExpr and
    deletedExpr.getASuccessor+() = throwingExpr
  )
select c, exceptionSource, functionNode, "Constructor throws $@ and allocates memory at $@",
  throwingExpr, throwingExpr.(ThrowingExpr).getAnExceptionType().getExceptionName(), newExpr,
  "alloc"
