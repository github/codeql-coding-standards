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

int getPrecision(BuiltInType type) {
  type.(CharType).isExplicitlyUnsigned() and result = type.(CharType).getSize() * 8
  or
  type.(ShortType).isExplicitlyUnsigned() and result = type.(ShortType).getSize() * 8
  or
  type.(IntType).isExplicitlyUnsigned() and result = type.(IntType).getSize() * 8
  or
  type.(LongType).isExplicitlyUnsigned() and result = type.(LongType).getSize() * 8
  or
  type.(LongLongType).isExplicitlyUnsigned() and result = type.(LongLongType).getSize() * 8
  or
  type instanceof CharType and
  not type.(CharType).isExplicitlyUnsigned() and
  result = type.(CharType).getSize() * 8 - 1
  or
  type instanceof ShortType and
  not type.(ShortType).isExplicitlyUnsigned() and
  result = type.(ShortType).getSize() * 8 - 1
  or
  type instanceof IntType and
  not type.(IntType).isExplicitlyUnsigned() and
  result = type.(IntType).getSize() * 8 - 1
  or
  type instanceof LongType and
  not type.(LongType).isExplicitlyUnsigned() and
  result = type.(LongType).getSize() * 8 - 1
  or
  type instanceof LongLongType and
  not type.(LongLongType).isExplicitlyUnsigned() and
  result = type.(LongLongType).getSize() * 8 - 1
}

predicate isForbiddenLShiftExpr(LShiftExpr binbitop, string message) {
  (
    (
      getPrecision(binbitop.getLeftOperand().getUnderlyingType()) <=
        upperBound(binbitop.getRightOperand()) and
      message =
        "The operand " + binbitop.getLeftOperand() + " is left-shifted by an expression " +
          binbitop.getRightOperand() + " which is greater than or equal to in precision."
      or
      lowerBound(binbitop.getRightOperand()) < 0 and
      message =
        "The operand " + binbitop.getLeftOperand() + " is left-shifted by a negative expression " +
          binbitop.getRightOperand() + "."
    )
    or
    /* Check a guard condition protecting the shift statement: heuristic (not an iff query) */
    exists(GuardCondition gc, BasicBlock block, Expr precisionCall |
      block = binbitop.getBasicBlock() and
      (
        precisionCall.(FunctionCall).getTarget() instanceof PopCount
        or
        precisionCall = any(PrecisionMacro pm).getAnInvocation().getExpr()
      )
    |
      /*
       * Shift statement is at a basic block where
       * `shift_rhs < PRECISION(...)` is ensured
       */

      not gc.ensuresLt(binbitop.getRightOperand(), precisionCall, 0, block, true)
    ) and
    message = "TODO"
  )
}

predicate isForbiddenRShiftExpr(RShiftExpr binbitop, string message) {
  (
    (
      getPrecision(binbitop.getLeftOperand().getUnderlyingType()) <=
        upperBound(binbitop.getRightOperand()) and
      message =
        "The operand " + binbitop.getLeftOperand() + " is right-shifted by an expression " +
          binbitop.getRightOperand() + " which is greater than or equal to in precision."
      or
      lowerBound(binbitop.getRightOperand()) < 0 and
      message =
        "The operand " + binbitop.getLeftOperand() + " is right-shifted by a negative expression " +
          binbitop.getRightOperand() + "."
    )
    or
    /* Check a guard condition protecting the shift statement: heuristic (not an iff query) */
    exists(GuardCondition gc, BasicBlock block, Expr precisionCall |
      block = binbitop.getBasicBlock() and
      (
        precisionCall.(FunctionCall).getTarget() instanceof PopCount
        or
        precisionCall = any(PrecisionMacro pm).getAnInvocation().getExpr()
      )
    |
      /*
       * Shift statement is at a basic block where
       * `shift_rhs < PRECISION(...)` is ensured
       */

      not gc.ensuresLt(binbitop.getRightOperand(), precisionCall, 0, block, true)
    ) and
    message = "TODO"
  )
}

from BinaryBitwiseOperation badShift, string message
where
  not isExcluded(badShift, TypesPackage::exprShiftedbyNegativeOrGreaterPrecisionOperandQuery()) and
  isForbiddenLShiftExpr(badShift, message)
  or
  isForbiddenRShiftExpr(badShift, message)
select badShift, message
