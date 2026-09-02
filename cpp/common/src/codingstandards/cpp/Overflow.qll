/**
 * This module provides predicates for checking whether an integer operation overflows, underflows or wraps.
 */

import cpp
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import SimpleRangeAnalysisCustomizations
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.dataflow.TaintTracking
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import codingstandards.cpp.Expr
import codingstandards.cpp.UndefinedBehavior

/**
 * An integer operation that may overflow, underflow or wrap.
 */
class InterestingOverflowingOperation extends Operation {
  InterestingOverflowingOperation() {
    // We are only interested in integer experssions
    this.getUnderlyingType() instanceof IntegralType and
    // Might overflow or underflow
    (
      exprMightOverflowNegatively(this)
      or
      exprMightOverflowPositively(this)
      or
      // Division and remainder are not handled by the library
      exists(DivOrRemOperation divOrRem | divOrRem = this |
        // The right hand side could be -1
        upperBound(divOrRem.getDivisor()) >= -1.0 and
        lowerBound(divOrRem.getDivisor()) <= -1.0 and
        // The left hand side could be the smallest possible integer value
        lowerBound(divOrRem.getDividend()) <=
          typeLowerBound(divOrRem.getDividend().getType().getUnderlyingType())
      )
    ) and
    // Multiplication is not covered by the standard range analysis library, so implement our own
    // mini analysis.
    (this instanceof MulExpr implies MulExprAnalysis::overflows(this)) and
    // This shouldn't be a "safe" crement operation
    not LoopCounterAnalysis::isCrementSafeFromOverflow(this) and
    // Not within a macro
    not this.isAffectedByMacro() and
    // Ignore pointer arithmetic
    not this instanceof PointerArithmeticOperation and
    // In case of the shift operation, it must cause undefined behavior
    (this instanceof BitShiftExpr implies this instanceof ShiftByNegativeOrGreaterPrecisionOperand)
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
      // For unsigned integer addition, look for this pattern:
      // if (x + y > x)
      //  use(x + y)
      // Ensuring it is not a bad overflow check
      (this instanceof AddExpr or this instanceof AssignAddExpr) and
      this.getType().getUnspecifiedType().(IntegralType).isUnsigned() and
      exists(AddExpr ae, RelationalOperation relOp |
        globalValueNumber(relOp.getAnOperand()) = i1 and
        relOp.getAnOperand() = ae and
        globalValueNumber(ae.getAnOperand()) = i1 and
        globalValueNumber(ae.getAnOperand()) = i2
      |
        // At least one operand is not smaller than int
        exists(Expr op | op = ae.getAnOperand() |
          op.getType().getSize() >= any(IntType i).getSize()
        )
        or
        // The result of the addition is explicitly converted to a smaller type before the comparison
        ae.getExplicitlyConverted().getType().getSize() < any(IntType i).getSize()
      )
      or
      // Match this pattern for checking for unsigned integer overflow on add
      // if (UINT_MAX - i1 < i2)
      (this instanceof AddExpr or this instanceof AssignAddExpr) and
      this.getType().getUnspecifiedType().(IntegralType).isUnsigned() and
      exists(SubExpr se, RelationalOperation relOp |
        globalValueNumber(relOp.getGreaterOperand()) = i2 and
        relOp.getAnOperand() = se and
        globalValueNumber(se.getRightOperand()) = i1 and
        se.getLeftOperand().getValue().toFloat() = typeUpperBound(getType())
      )
      or
      // Match this pattern for checking for unsigned integer underflow on subtract
      // if (i1 < i2)
      (this instanceof SubExpr or this instanceof AssignSubExpr) and
      this.getType().getUnspecifiedType().(IntegralType).isUnsigned() and
      exists(RelationalOperation relOp |
        globalValueNumber(relOp.getGreaterOperand()) = i2 and
        globalValueNumber(relOp.getLesserOperand()) = i1
      )
      or
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
      // CERT recommends checking for divisor != -1 and dividor != INT_MIN
      this instanceof DivOrRemOperation and
      exists(EqualityOperation eop |
        // GuardCondition doesn't work in this case, so just confirm that this check dominates the overflow
        globalValueNumber(eop.getAnOperand()) = i1 and
        eop.getAnOperand().getValue().toFloat() =
          typeLowerBound(this.(DivOrRemOperation).getDividend().getType().getUnderlyingType())
      ) and
      exists(EqualityOperation eop |
        // GuardCondition doesn't work in this case, so just confirm that this check dominates the overflow
        globalValueNumber(eop.getAnOperand()) = i2 and
        eop.getAnOperand().getValue().toInt() = -1
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
  predicate hasValidPostCheck() { exists(getAValidPostCheck()) }

  /**
   * Gets a correct validity check, `gc`, after this expression which may overflow.
   */
  GuardCondition getAValidPostCheck() {
    this.getType().(IntegralType).isUnsigned() and
    (
      exists(RelationalOperation ro |
        DataFlow::localExprFlow(this, ro.getLesserOperand()) and
        globalValueNumber(ro.getGreaterOperand()) = globalValueNumber(this.getAnOperand()) and
        (this instanceof AddExpr or this instanceof AssignAddExpr) and
        result = ro
      )
      or
      exists(RelationalOperation ro |
        DataFlow::localExprFlow(this, ro.getGreaterOperand()) and
        globalValueNumber(ro.getLesserOperand()) = globalValueNumber(this.getAnOperand()) and
        (this instanceof SubExpr or this instanceof AssignSubExpr) and
        result = ro
      )
    )
  }
}

private class StrictRelationalOperation extends RelationalOperation {
  StrictRelationalOperation() { this.getOperator() = [">", "<"] }
}

class DivOrRemOperation extends Operation {
  DivOrRemOperation() {
    this instanceof DivExpr or
    this instanceof RemExpr or
    this instanceof AssignDivExpr or
    this instanceof AssignRemExpr
  }

  Expr getDividend() {
    result = this.(BinaryOperation).getLeftOperand() or
    result = this.(AssignArithmeticOperation).getLValue()
  }

  Expr getDivisor() {
    result = this.(BinaryOperation).getRightOperand() or
    result = this.(AssignArithmeticOperation).getRValue()
  }
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

/**
 * An analysis on safe loop counters.
 */
module LoopCounterAnalysis {
  newtype LoopBound =
    LoopUpperBound() or
    LoopLowerBound()

  predicate isLoopBounded(
    CrementOperation cop, ForStmt fs, Variable loopCounter, Expr initializer, Expr counterBound,
    LoopBound boundKind, boolean equals
  ) {
    // Initialization sets the loop counter
    (
      loopCounter = fs.getInitialization().(DeclStmt).getADeclaration() and
      initializer = loopCounter.getInitializer().getExpr()
      or
      loopCounter.getAnAssignment() = initializer and
      initializer = fs.getInitialization().(ExprStmt).getExpr()
    ) and
    // Condition is a relation operation on the loop counter
    exists(RelationalOperation relOp |
      fs.getCondition() = relOp and
      (if relOp.getOperator().charAt(1) = "=" then equals = true else equals = false)
    |
      relOp.getGreaterOperand() = loopCounter.getAnAccess() and
      relOp.getLesserOperand() = counterBound and
      cop instanceof DecrementOperation and
      boundKind = LoopLowerBound()
      or
      relOp.getLesserOperand() = loopCounter.getAnAccess() and
      relOp.getGreaterOperand() = counterBound and
      cop instanceof IncrementOperation and
      boundKind = LoopUpperBound()
    ) and
    // Update is a crement operation with the loop counter
    fs.getUpdate() = cop and
    cop.getOperand() = loopCounter.getAnAccess()
  }

  /**
   * Holds if the crement operation is safe from under/overflow.
   */
  predicate isCrementSafeFromOverflow(CrementOperation op) {
    exists(
      Expr initializer, Expr counterBound, LoopBound boundKind, boolean equals, int equalsOffset
    |
      isLoopBounded(op, _, _, initializer, counterBound, boundKind, equals) and
      (
        equals = true and equalsOffset = 1
        or
        equals = false and equalsOffset = 0
      )
    |
      boundKind = LoopUpperBound() and
      // upper bound of the inccrement is smaller than the maximum value representable in the type
      upperBound(counterBound) + equalsOffset <= typeUpperBound(op.getType().getUnspecifiedType())
      or
      // the lower bound of the decrement is larger than the smal
      boundKind = LoopLowerBound() and
      lowerBound(counterBound) - equalsOffset >= typeLowerBound(op.getType().getUnspecifiedType())
    )
  }
}
