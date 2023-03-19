/**
 * This module provides predicates for checking whether an operation overflows or wraps.
 */

import cpp
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import SimpleRangeAnalysisCustomizations
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

/**
 * A `BinaryArithmeticOperation` which may overflow and is a potentially interesting case to review
 * that is not covered by other queries for this rule.
 */
class InterestingBinaryOverflowingExpr extends BinaryArithmeticOperation {
  InterestingBinaryOverflowingExpr() {
    // Might overflow or underflow
    (
      exprMightOverflowNegatively(this)
      or
      exprMightOverflowPositively(this)
    ) and
    not this.isAffectedByMacro() and
    // Ignore pointer arithmetic
    not this instanceof PointerArithmeticOperation and
    // Covered by `IntMultToLong.ql` instead
    not this instanceof MulExpr and
    // Not covered by this query - overflow/underflow in division is rare
    not this instanceof DivExpr
  }

  /**
   * Get a `GVN` which guards this expression which may overflow.
   */
  GVN getAGuardingGVN() {
    exists(GuardCondition gc, Expr e |
      not gc = getABadOverflowCheck() and
      TaintTracking::localTaint(DataFlow::exprNode(e), DataFlow::exprNode(gc.getAChild*())) and
      gc.controls(this.getBasicBlock(), _) and
      result = globalValueNumber(e)
    )
  }

  /**
   * Identifies a bad overflow check for this overflow expression.
   */
  GuardCondition getABadOverflowCheck() {
    exists(AddExpr ae, RelationalOperation relOp |
      this = ae and
      result = relOp and
      // Looking for this pattern:
      // if (x + y > x)
      //  use(x + y)
      //
      globalValueNumber(relOp.getAnOperand()) = globalValueNumber(ae) and
      globalValueNumber(relOp.getAnOperand()) = globalValueNumber(ae.getAnOperand())
    |
      // Signed overflow checks are insufficient
      ae.getUnspecifiedType().(IntegralType).isSigned()
      or
      // Unsigned overflow checks can still be bad, if the result is promoted.
      forall(Expr op | op = ae.getAnOperand() | op.getType().getSize() < any(IntType i).getSize()) and
      // Not explicitly converted to a smaller type before the comparison
      not ae.getExplicitlyConverted().getType().getSize() < any(IntType i).getSize()
    )
  }
}
