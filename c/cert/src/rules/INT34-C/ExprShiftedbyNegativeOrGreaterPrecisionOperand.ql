/**
 * @id c/cert/expr-shiftedby-negative-or-greater-precision-operand
 * @name INT34-C: Bit shift should not be done by a negative operand or an operand of greater-or-equal precision than that of another
 * @description Shifting an expression by an operand that is negative or of precision greater or
 *              equal to that or the another causes representational error.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/int34-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.controlflow.Guards

/*
 * Precision predicate based on a sample implementation from
 * https://wiki.sei.cmu.edu/confluence/display/c/INT35-C.+Use+correct+integer+precisions
 */

/**
 * A function whose name is suggestive that it counts the number of bits set.
 */
class PopCount extends Function {
  PopCount() { this.getName().toLowerCase().matches("%popc%nt%") }
}

/**
 * A macro which is suggestive that it is used to determine the precision of an integer.
 */
class PrecisionMacro extends Macro {
  PrecisionMacro() { this.getName().toLowerCase().matches("precision") }
}

class LiteralZero extends Literal {
  LiteralZero() { this.getValue() = "0" }
}

class BitShiftExpr extends BinaryBitwiseOperation {
  BitShiftExpr() {
    this instanceof LShiftExpr or
    this instanceof RShiftExpr
  }
}

int getPrecision(IntegralType type) {
  type.isExplicitlyUnsigned() and result = type.getSize() * 8
  or
  type.isExplicitlySigned() and result = type.getSize() * 8 - 1
}

predicate isForbiddenShiftExpr(BitShiftExpr shift, string message) {
  (
    (
      getPrecision(shift.getLeftOperand().getExplicitlyConverted().getUnderlyingType()) <=
        upperBound(shift.getRightOperand()) and
      message =
        "The operand " + shift.getLeftOperand() + " is shifted by an expression " +
          shift.getRightOperand() + " whose upper bound (" + upperBound(shift.getRightOperand()) +
          ") is greater than or equal to the precision."
      or
      lowerBound(shift.getRightOperand()) < 0 and
      message =
        "The operand " + shift.getLeftOperand() + " is shifted by an expression " +
          shift.getRightOperand() + " which may be negative."
    ) and
    /*
     * Shift statement is not at a basic block where
     * `shift_rhs < PRECISION(...)` is ensured
     */

    not exists(GuardCondition gc, BasicBlock block, Expr precisionCall, Expr lTLhs |
      block = shift.getBasicBlock() and
      (
        precisionCall.(FunctionCall).getTarget() instanceof PopCount
        or
        precisionCall = any(PrecisionMacro pm).getAnInvocation().getExpr()
      )
    |
      globalValueNumber(lTLhs) = globalValueNumber(shift.getRightOperand()) and
      gc.ensuresLt(lTLhs, precisionCall, 0, block, true)
    ) and
    /*
     * Shift statement is not at a basic block where
     * `shift_rhs < 0` is ensured
     */

    not exists(GuardCondition gc, BasicBlock block, Expr literalZero, Expr lTLhs |
      block = shift.getBasicBlock() and
      literalZero instanceof LiteralZero
    |
      globalValueNumber(lTLhs) = globalValueNumber(shift.getRightOperand()) and
      gc.ensuresLt(lTLhs, literalZero, 0, block, true)
    )
  )
}

from BinaryBitwiseOperation badShift, string message
where
  not isExcluded(badShift, Types1Package::exprShiftedbyNegativeOrGreaterPrecisionOperandQuery()) and
  isForbiddenShiftExpr(badShift, message)
select badShift, message
