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
 * An operation that may overflow or underflow.
 */
class InterestingOverflowingOperation extends Operation {
  InterestingOverflowingOperation() {
    // Might overflow or underflow
    (
      exprMightOverflowNegatively(this)
      or
      exprMightOverflowPositively(this)
    ) and
    // Multiplication is not covered by the standard range analysis library, so implement our own
    // mini analysis.
    (this instanceof MulExpr implies MulExprAnalysis::overflows(this)) and
    // Not within a macro
    not this.isAffectedByMacro() and
    // Ignore pointer arithmetic
    not this instanceof PointerArithmeticOperation
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
    // For binary operations (both arithmetic operations and arithmetic assignment operations)
    exists(GVN i1, GVN i2, Expr op1, Expr op2 |
      op1 = getAnOperand() and
      op2 = getAnOperand() and
      not op1 = op2 and
      i1 = globalValueNumber(op1) and
      i2 = globalValueNumber(op2)
    |
      // The CERT rule for signed integer overflow has a very specific pattern it recommends
      // for checking for overflow. We try to match the pattern here.
      //   ((i2 > 0 && i1 > (INT_MAX - i2)) || (i2 < 0 && i1 < (INT_MIN - i2)))
      (this instanceof AddExpr or this instanceof AssignAddExpr) and
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
      (this instanceof SubExpr or this instanceof AssignSubExpr) and
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
      or
      // The CERT rule for signed integer overflow has a very specific pattern it recommends
      // for checking for multiplication underflow/overflow. We just use a heuristic here,
      // which determines if at least 4 checks of the sort `a < INT_MAX / b` are present in the code.
      (this instanceof MulExpr or this instanceof AssignMulExpr) and
      count(StrictRelationalOperation rel |
        globalValueNumber(rel.getAnOperand()) = i1 and
        globalValueNumber(rel.getAnOperand().(DivExpr).getRightOperand()) = i2
        or
        globalValueNumber(rel.getAnOperand()) = i2 and
        globalValueNumber(rel.getAnOperand().(DivExpr).getRightOperand()) = i1
      ) >= 4
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
        (this instanceof AddExpr or this instanceof AssignAddExpr) and
        ro instanceof GuardCondition
      )
      or
      exists(RelationalOperation ro |
        DataFlow::localExprFlow(this, ro.getGreaterOperand()) and
        globalValueNumber(ro.getLesserOperand()) = globalValueNumber(this.getAnOperand()) and
        (this instanceof SubExpr or this instanceof AssignSubExpr) and
        ro instanceof GuardCondition
      )
    )
  }

  /**
   * Identifies a bad overflow check for this overflow expression.
   */
  GuardCondition getABadOverflowCheck() {
    exists(RelationalOperation relOp |
      (this instanceof AddExpr or this instanceof AssignAddExpr) and
      result = relOp and
      // Looking for this pattern:
      // if (x + y > x)
      //  use(x + y)
      //
      globalValueNumber(relOp.getAnOperand()) = globalValueNumber(this) and
      globalValueNumber(relOp.getAnOperand()) = globalValueNumber(this.getAnOperand())
    |
      // Signed overflow checks are insufficient
      this.getUnspecifiedType().(IntegralType).isSigned()
      or
      // Unsigned overflow checks can still be bad, if the result is promoted.
      forall(Expr op | op = this.getAnOperand() | op.getType().getSize() < any(IntType i).getSize()) and
      // Not explicitly converted to a smaller type before the comparison
      not this.getExplicitlyConverted().getType().getSize() < any(IntType i).getSize()
    )
  }
}

private class StrictRelationalOperation extends RelationalOperation {
  StrictRelationalOperation() { this.getOperator() = [">", "<"] }
}

/**
 * Module inspired by the IntMultToLong.ql query.
 */
private module MulExprAnalysis {
  /**
   * As SimpleRangeAnalysis does not support reasoning about multiplication
   * we create a tiny abstract interpreter for handling multiplication, which
   * we invoke only after weeding out of all of trivial cases that we do
   * not care about. By default, the maximum and minimum values are computed
   * using SimpleRangeAnalysis.
   */
  class AnalyzableExpr extends Expr {
    AnalyzableExpr() {
      // A integer multiplication, or an expression within an integral expression
      this.(MulExpr).getType().getUnspecifiedType() instanceof IntegralType or
      this.getParent() instanceof AnalyzableExpr or
      this.(Conversion).getExpr() instanceof AnalyzableExpr
    }

    float maxValue() { result = upperBound(this.getFullyConverted()) }

    float minValue() { result = lowerBound(this.getFullyConverted()) }
  }

  class ParenAnalyzableExpr extends AnalyzableExpr, ParenthesisExpr {
    override float maxValue() { result = this.getExpr().(AnalyzableExpr).maxValue() }

    override float minValue() { result = this.getExpr().(AnalyzableExpr).minValue() }
  }

  class MulAnalyzableExpr extends AnalyzableExpr, MulExpr {
    override float maxValue() {
      exists(float x1, float y1, float x2, float y2 |
        x1 = this.getLeftOperand().getFullyConverted().(AnalyzableExpr).minValue() and
        x2 = this.getLeftOperand().getFullyConverted().(AnalyzableExpr).maxValue() and
        y1 = this.getRightOperand().getFullyConverted().(AnalyzableExpr).minValue() and
        y2 = this.getRightOperand().getFullyConverted().(AnalyzableExpr).maxValue() and
        result = (x1 * y1).maximum(x1 * y2).maximum(x2 * y1).maximum(x2 * y2)
      )
    }

    override float minValue() {
      exists(float x1, float x2, float y1, float y2 |
        x1 = this.getLeftOperand().getFullyConverted().(AnalyzableExpr).minValue() and
        x2 = this.getLeftOperand().getFullyConverted().(AnalyzableExpr).maxValue() and
        y1 = this.getRightOperand().getFullyConverted().(AnalyzableExpr).minValue() and
        y2 = this.getRightOperand().getFullyConverted().(AnalyzableExpr).maxValue() and
        result = (x1 * y1).minimum(x1 * y2).minimum(x2 * y1).minimum(x2 * y2)
      )
    }
  }

  /**
   * Analyze add expressions directly. This handles the case where an add expression is contributed to
   * by a multiplication.
   */
  class AddAnalyzableExpr extends AnalyzableExpr, AddExpr {
    override float maxValue() {
      result =
        this.getLeftOperand().getFullyConverted().(AnalyzableExpr).maxValue() +
          this.getRightOperand().getFullyConverted().(AnalyzableExpr).maxValue()
    }

    override float minValue() {
      result =
        this.getLeftOperand().getFullyConverted().(AnalyzableExpr).minValue() +
          this.getRightOperand().getFullyConverted().(AnalyzableExpr).minValue()
    }
  }

  /**
   * Analyze sub expressions directly. This handles the case where a sub expression is contributed to
   * by a multiplication.
   */
  class SubAnalyzableExpr extends AnalyzableExpr, SubExpr {
    override float maxValue() {
      result =
        this.getLeftOperand().getFullyConverted().(AnalyzableExpr).maxValue() -
          this.getRightOperand().getFullyConverted().(AnalyzableExpr).minValue()
    }

    override float minValue() {
      result =
        this.getLeftOperand().getFullyConverted().(AnalyzableExpr).minValue() -
          this.getRightOperand().getFullyConverted().(AnalyzableExpr).maxValue()
    }
  }

  predicate overflows(MulExpr me) {
    me.(MulAnalyzableExpr).maxValue() > exprMaxVal(me)
    or
    me.(MulAnalyzableExpr).minValue() < exprMinVal(me)
  }
}
