/**
 * @id c/cert/insufficient-memory-allocated-for-object
 * @name MEM35-C: Allocate sufficient memory for an object
 * @description The size of memory allocated dynamically must be adequate to represent the type of
 *              object referenced by the allocated memory.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/mem35-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Overflow
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.models.Models

/**
 * Gets the type of the operand of `op`.
 */
Type getSizeofOperatorType(SizeofOperator op) {
  result = op.(SizeofExprOperator).getExprOperand().getType()
  or
  result = op.(SizeofTypeOperator).getTypeOperand()
}

/**
 * A function call which allocates memory, such as `malloc`.
 */
class AllocationFunctionCall extends AllocationExpr, FunctionCall {
  AllocationFunctionCall() { this.getTarget() instanceof AllocationFunction }

  /**
   * Gets the size argument `Expr` of this allocation function call.
   */
  Expr getSizeArg() {
    result = this.getArgument(this.getTarget().(AllocationFunction).getSizeArg())
  }

  /**
   * Gets the computed value of the size argument of this allocation function call.
   */
  int getSizeExprValue() { result = upperBound(this.getSizeArg()) }

  /**
   * Gets the type of the object the allocation function result is assigned to.
   *
   * If the allocation is not assigned to a variable, this predicate does not hold.
   */
  Type getBaseType() {
    exists(PointerType pointer |
      pointer.getBaseType() = result and
      (
        exists(AssignExpr assign |
          assign.getRValue() = this and assign.getLValue().getType() = pointer
        )
        or
        exists(Variable v | v.getInitializer().getExpr() = this and v.getType() = pointer)
      )
    )
  }

  /**
   * Gets a message describing the problem with this allocation function call.
   * The `e` and `description` respectively provide an expression that influences
   * the size of the allocation and a string describing that expression.
   */
  string getMessageAndSourceInfo(Expr e, string description) { none() }
}

/**
 * An `AllocationFunctionCall` where the size argument is tainted by a `SizeofOperator`
 * that has an operand of a different type than the base type of the variable assigned
 * the result of the allocation call.
 */
class WrongSizeofOperatorAllocationFunctionCall extends AllocationFunctionCall {
  SizeofOperator source;

  WrongSizeofOperatorAllocationFunctionCall() {
    this.getBaseType() != getSizeofOperatorType(source) and
    TaintTracking::localExprTaint(source, this.getSizeArg().getAChild*())
  }

  override string getMessageAndSourceInfo(Expr e, string description) {
    result = "Allocation size calculated from the size of a different type ($@)." and
    e = source and
    description = "sizeof(" + getSizeofOperatorType(source).getName() + ")"
  }
}

/**
 * An `AllocationFunctionCall` that allocates a size that is not a multiple
 * of the size of the base type of the variable assigned the allocation.
 *
 * For example, an allocation of 14 bytes for `float` (`sizeof(float) == 4`)
 * indicates an erroroneous allocation size, as 14 is not a multiple of 4 and
 * thus cannot be the exact size of an array of floats.
 *
 * This class cannot also be a `WrongSizeofOperatorAllocationFunctionCall` instance,
 * as an identified `SizeofOperator` operand type mismatch is more likely to indicate
 * the root cause of an allocation size that is not a multiple of the base type size.
 */
class WrongSizeMultipleAllocationFunctionCall extends AllocationFunctionCall {
  WrongSizeMultipleAllocationFunctionCall() {
    // de-duplicate results if there is more precise info from a sizeof operator
    not this instanceof WrongSizeofOperatorAllocationFunctionCall and
    // the allocation size is not a multiple of the base type size
    exists(int basesize, int allocated |
      basesize = min(this.getBaseType().getSize()) and
      allocated = this.getSizeExprValue() and
      not exists(int size | this.getBaseType().getSize() = size |
        size = 0 or
        (allocated / size) * size = allocated
      )
    )
  }

  override string getMessageAndSourceInfo(Expr e, string description) {
    result =
      "Allocation size (" + this.getSizeExprValue().toString() +
        " bytes) is not a multiple of the size of '" + this.getBaseType().getName() + "' (" +
        min(this.getBaseType().getSize()).toString() + " bytes)." and
    e = this.getSizeArg() and
    description = ""
  }
}

/**
 * An `AllocationFunctionCall` where the size argument might be tainted by an overflowing
 * or wrapping integer expression that is not checked for validity before the allocation.
 */
class OverflowingSizeAllocationFunctionCall extends AllocationFunctionCall {
  InterestingOverflowingOperation bop;

  OverflowingSizeAllocationFunctionCall() {
    // `bop` is not pre-checked to prevent overflow/wrapping
    not bop.hasValidPreCheck() and
    // and the size argument is tainted by `bop`
    TaintTracking::localExprTaint(bop, this.getSizeArg().getAChild*()) and
    // and there does not exist a post-wrapping-check before the allocation call
    not exists(GuardCondition gc |
      gc = bop.getAValidPostCheck() and
      gc.controls(this.getBasicBlock(), _)
    )
  }

  override string getMessageAndSourceInfo(Expr e, string description) {
    result = "Allocation size derived from potentially overflowing or wrapping $@." and
    e = bop and
    description = "integer operation"
  }
}

from AllocationFunctionCall alloc, string message, Expr source, string sourceMessage
where
  not isExcluded(alloc, Memory3Package::insufficientMemoryAllocatedForObjectQuery()) and
  message = alloc.getMessageAndSourceInfo(source, sourceMessage)
select alloc, message, source, sourceMessage
