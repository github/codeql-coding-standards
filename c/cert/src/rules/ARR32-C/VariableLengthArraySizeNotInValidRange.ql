/**
 * @id c/cert/variable-length-array-size-not-in-valid-range
 * @name ARR32-C: Ensure size arguments for variable length arrays are in a valid range
 * @description A variable-length array size that is zero, negative, overflowed, wrapped around, or
 *              excessively large may lead to undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/arr32-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Overflow

/**
 * Gets the maximum size (in bytes) a variable-length array
 * should be to not be deemed excessively large persuant to this rule.
 * This value has been arbitrarily chosen to be 2^16 - 1 bytes.
 */
private int maximumTotalVlaSize() { result = 65535 }

/**
 * Gets the base type of a pointer or array type.  In the case of an array of
 * arrays, the inner base type is returned.
 *
 * Copied from IncorrectPointerScalingCommon.qll.
 */
private Type baseType(Type t) {
  (
    exists(PointerType dt |
      dt = t.getUnspecifiedType() and
      result = dt.getBaseType().getUnspecifiedType()
    )
    or
    exists(ArrayType at |
      at = t.getUnspecifiedType() and
      not at.getBaseType().getUnspecifiedType() instanceof ArrayType and
      result = at.getBaseType().getUnspecifiedType()
    )
    or
    exists(ArrayType at, ArrayType at2 |
      at = t.getUnspecifiedType() and
      at2 = at.getBaseType().getUnspecifiedType() and
      result = baseType(at2)
    )
  ) and
  // Make sure that the type has a size and that it isn't ambiguous.
  strictcount(result.getSize()) = 1
}

/**
 * The `SimpleRangeAnalysis` analysis over-zealously expands upper bounds of
 * `SubExpr`s to account for potential wrapping even when no wrapping can occur.
 *
 * This class represents a `SubExpr` that is safe from wrapping.
 */
class SafeSubExprWithErroneouslyWrappedUpperBound extends SubExpr {
  SafeSubExprWithErroneouslyWrappedUpperBound() {
    lowerBound(this.getLeftOperand().getFullyConverted()) -
      upperBound(this.getRightOperand().getFullyConverted()) >= 0 and
    upperBound(this.getFullyConverted()) = exprMaxVal(this.getFullyConverted())
  }

  /**
   * Gets the lower bound of the difference.
   */
  float getlowerBoundOfDifference() {
    result =
      lowerBound(this.getLeftOperand().getFullyConverted()) -
        upperBound(this.getRightOperand().getFullyConverted())
  }
}

/**
 * Holds if `e` is an expression that is not in a valid range due to it
 * being partially or fully derived from an overflowing arithmetic operation.
 */
predicate isExprTaintedByOverflowingExpr(Expr e) {
  exists(InterestingOverflowingOperation bop |
    // `bop` is not pre-checked to prevent overflow/wrapping
    not bop.hasValidPreCheck() and
    // and the destination is tainted by `bop`
    TaintTracking::localExprTaint(bop, e.getAChild*()) and
    // and there does not exist a post-wrapping-check before `e`
    not exists(GuardCondition gc |
      gc = bop.getAValidPostCheck() and
      gc.controls(e.getBasicBlock(), _)
    )
  )
}

predicate getVlaSizeExprBounds(Expr e, float lower, float upper) {
  lower = lowerBound(e) and
  upper =
    // upper is the smallest of either a `SubExpr` which flows to `e` and does
    // not wrap, or the upper bound of `e` derived from the range-analysis library
    min(float f |
      f =
        any(SafeSubExprWithErroneouslyWrappedUpperBound sub |
          DataFlow::localExprFlow(sub, e)
        |
          sub.getlowerBoundOfDifference()
        ) or
      f = upperBound(e)
    )
}

/**
 * Holds if `e` is not bounded to a valid range, (0 .. maximumTotalVlaSize()], for
 * a element count of an individual variable-length array dimension.
 */
predicate isVlaSizeExprOutOfRange(VlaDeclStmt vla, Expr e) {
  vla.getVlaDimensionStmt(_).getDimensionExpr() = e and
  exists(float lower, float upper |
    getVlaSizeExprBounds(e.getFullyConverted(), lower, upper) and
    (
      lower <= 0
      or
      upper > maximumTotalVlaSize() / baseType(vla.getVariable().getType()).getSize()
    )
  )
}

/**
 * Returns the upper bound of `e.getFullyConverted()`.
 */
float getVlaSizeExprUpperBound(Expr e) { getVlaSizeExprBounds(e.getFullyConverted(), _, result) }

/**
 * Returns the upper bound of `vla`'s dimension expression at `index`.
 *
 * If `index` does not exist, then the result is `1`.
 */
bindingset[index]
private float getVlaSizeExprUpperBoundAtIndexOrOne(VlaDeclStmt vla, float index) {
  if vla.getNumberOfVlaDimensionStmts() > index
  then result = getVlaSizeExprUpperBound(vla.getVlaDimensionStmt(index).getDimensionExpr())
  else result = 1
}

predicate vlaupper = getVlaSizeExprUpperBoundAtIndexOrOne/2;

/**
 * Gets the upper bound of the total size of `vla`.
 */
float getTotalVlaSizeUpperBound(VlaDeclStmt vla) {
  result =
    vlaupper(vla, 0) * vlaupper(vla, 1) * vlaupper(vla, 2) * vlaupper(vla, 3) * vlaupper(vla, 4) *
      vlaupper(vla, 5) * vlaupper(vla, 6) * vlaupper(vla, 7) * vlaupper(vla, 8) * vlaupper(vla, 9)
}

from VlaDeclStmt vla, string message
where
  not isExcluded(vla, InvalidMemory2Package::variableLengthArraySizeNotInValidRangeQuery()) and
  (
    if isExprTaintedByOverflowingExpr(vla.getVlaDimensionStmt(_).getDimensionExpr())
    then message = "Variable-length array size derives from an overflowing or wrapping expression."
    else (
      if isVlaSizeExprOutOfRange(vla, vla.getVlaDimensionStmt(_).getDimensionExpr())
      then message = "Variable-length array dimension size may be in an invalid range."
      else (
        getTotalVlaSizeUpperBound(vla) > maximumTotalVlaSize() and
        message = "Variable-length array total size may be excessively large."
      )
    )
  )
select vla, message
