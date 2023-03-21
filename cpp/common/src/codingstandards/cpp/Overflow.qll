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
   * Holds if there is a correct validity check after this expression which may overflow.
   */
  predicate hasValidPreCheck() {
    exists(GVN i1, GVN i2 |
      i1 = globalValueNumber(this.getLeftOperand()) and
      i2 = globalValueNumber(this.getRightOperand())
      or
      i2 = globalValueNumber(this.getLeftOperand()) and
      i1 = globalValueNumber(this.getRightOperand())
    |
      // The CERT rule for signed integer overflow has a very specific pattern it recommends
      // for checking for overflow. We try to match the pattern here.
      //   ((i2 > 0 && i1 > (INT_MAX - i2)) || (i2 < 0 && i1 < (INT_MIN - i2)))
      this instanceof AddExpr and
      exists(LogicalOrExpr orExpr |
        // GuardCondition doesn't work in this case, so just confirm that this check dominates the overflow
        bbDominates(orExpr.getBasicBlock(), this.getBasicBlock()) and
        exists(LogicalAndExpr andExpr |
          andExpr = orExpr.getAnOperand() and
          exists(StrictRelationalOperation gt |
            gt = andExpr.getAnOperand() and
            gt.getLesserOperand().getValue() = "0" and
            globalValueNumber(gt.getGreaterOperand()) = i2
          ) and
          exists(StrictRelationalOperation gt |
            gt = andExpr.getAnOperand() and
            gt.getLesserOperand() =
              any(SubExpr se |
                se.getLeftOperand().getValue().toFloat() = typeUpperBound(getType()) and
                globalValueNumber(se.getRightOperand()) = i2
              ) and
            globalValueNumber(gt.getGreaterOperand()) = i1
          )
        ) and
        exists(LogicalAndExpr andExpr |
          andExpr = orExpr.getAnOperand() and
          exists(StrictRelationalOperation gt |
            gt = andExpr.getAnOperand() and
            gt.getGreaterOperand().getValue() = "0" and
            globalValueNumber(gt.getLesserOperand()) = i2
          ) and
          exists(StrictRelationalOperation gt |
            gt = andExpr.getAnOperand() and
            gt.getGreaterOperand() =
              any(SubExpr se |
                se.getLeftOperand().getValue().toFloat() = typeLowerBound(getType()) and
                globalValueNumber(se.getRightOperand()) = i2
              ) and
            globalValueNumber(gt.getLesserOperand()) = i1
          )
        )
      )
      or
      // The CERT rule for signed integer overflow has a very specific pattern it recommends
      // for checking for underflow. We try to match the pattern here.
      //   ((i2 > 0 && i1 > (INT_MIN + i2)) || (i2 < 0 && i1 < (INT_MAX + i2)))
      this instanceof SubExpr and
      exists(LogicalOrExpr orExpr |
        // GuardCondition doesn't work in this case, so just confirm that this check dominates the overflow
        bbDominates(orExpr.getBasicBlock(), this.getBasicBlock()) and
        exists(LogicalAndExpr andExpr |
          andExpr = orExpr.getAnOperand() and
          exists(StrictRelationalOperation gt |
            gt = andExpr.getAnOperand() and
            gt.getLesserOperand().getValue() = "0" and
            globalValueNumber(gt.getGreaterOperand()) = i2
          ) and
          exists(StrictRelationalOperation gt |
            gt = andExpr.getAnOperand() and
            gt.getGreaterOperand() =
              any(AddExpr se |
                se.getLeftOperand().getValue().toFloat() = typeLowerBound(getType()) and
                globalValueNumber(se.getRightOperand()) = i2
              ) and
            globalValueNumber(gt.getLesserOperand()) = i1
          )
        ) and
        exists(LogicalAndExpr andExpr |
          andExpr = orExpr.getAnOperand() and
          exists(StrictRelationalOperation gt |
            gt = andExpr.getAnOperand() and
            gt.getGreaterOperand().getValue() = "0" and
            globalValueNumber(gt.getLesserOperand()) = i2
          ) and
          exists(StrictRelationalOperation gt |
            gt = andExpr.getAnOperand() and
            gt.getLesserOperand() =
              any(AddExpr se |
                se.getLeftOperand().getValue().toFloat() = typeUpperBound(getType()) and
                globalValueNumber(se.getRightOperand()) = i2
              ) and
            globalValueNumber(gt.getGreaterOperand()) = i1
          )
        )
      )
    )
  }

  /**
   * Holds if there is a correct validity check after this expression which may overflow.
   *
   * Only holds for unsigned expressions, as signed overflow/underflow are undefined behavior.
   */
  predicate hasValidPostCheck() {
    this.getType().(IntegralType).isUnsigned() and
    (
      exists(RelationalOperation ro |
        DataFlow::localExprFlow(this, ro.getLesserOperand()) and
        globalValueNumber(ro.getGreaterOperand()) = globalValueNumber(this.getAnOperand()) and
        this instanceof AddExpr and
        ro instanceof GuardCondition
      )
      or
      exists(RelationalOperation ro |
        DataFlow::localExprFlow(this, ro.getGreaterOperand()) and
        globalValueNumber(ro.getLesserOperand()) = globalValueNumber(this.getAnOperand()) and
        this instanceof SubExpr and
        ro instanceof GuardCondition
      )
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

private class StrictRelationalOperation extends RelationalOperation {
  StrictRelationalOperation() { this.getOperator() = [">", "<"] }
}
