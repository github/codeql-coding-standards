import cpp
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.controlflow.Guards
import codingstandards.cpp.Literals
import codingstandards.cpp.Expr
import codingstandards.cpp.Macro
import codingstandards.cpp.Type
import codingstandards.cpp.Function

/**
 * Library for modeling undefined behavior.
 */
abstract class UndefinedBehavior extends Locatable {
  abstract string getReason();
}

abstract class CPPUndefinedBehavior extends UndefinedBehavior { }

class ShiftByNegativeOrGreaterPrecisionOperand extends UndefinedBehavior, BitShiftExpr {
  string reason;

  ShiftByNegativeOrGreaterPrecisionOperand() {
    getPrecision(this.getLeftOperand().getExplicitlyConverted().getUnderlyingType()) <=
      upperBound(this.getRightOperand()) and
    reason =
      "The operand  '" + this.getLeftOperand() + "' is shifted by an expression '" +
        this.getRightOperand() + "' whose upper bound (" + upperBound(this.getRightOperand()) +
        ") is greater than or equal to the precision." and
    /*
     * this statement is not at a basic block where
     * `this_rhs < PRECISION(...)` is ensured
     */

    not exists(GuardCondition gc, BasicBlock block, Expr precisionCall, Expr lTLhs |
      block = this.getBasicBlock() and
      (
        precisionCall.(FunctionCall).getTarget() instanceof PopCount
        or
        precisionCall = any(PrecisionMacro pm).getAnInvocation().getExpr()
      )
    |
      globalValueNumber(lTLhs) = globalValueNumber(this.getRightOperand()) and
      gc.ensuresLt(lTLhs, precisionCall, 0, block, true)
    )
    or
    lowerBound(this.getRightOperand()) < 0 and
    reason =
      "The operand '" + this.getLeftOperand() + "' is shifted by an expression '" +
        this.getRightOperand() + "' which may be negative." and
    /*
     * this statement is not at a basic block where
     * `this_rhs > 0` is ensured
     */

    not exists(GuardCondition gc, BasicBlock block, Expr literalZero, Expr lTLhs |
      block = this.getBasicBlock() and
      literalZero instanceof LiteralZero and
      globalValueNumber(lTLhs) = globalValueNumber(this.getRightOperand()) and
      gc.ensuresLt(literalZero, lTLhs, 0, block, true)
    )
  }

  override string getReason() { result = reason }
}
