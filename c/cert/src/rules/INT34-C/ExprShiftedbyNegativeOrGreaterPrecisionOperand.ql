/**
 * @id c/cert/expr-shiftedby-negative-or-greater-precision-operand
 * @name INT34-C: Bit shift should not be done by a negative operand or an operand of greater-or-equal precision than that of another
 * @description Shifting an expression by an operand that is negative or of precision greater or
 *              equal to that or the another causes representational error.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/int34-c
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.controlflow.Guards
import codingstandards.cpp.UndefinedBehavior

from ShiftByNegativeOrGreaterPrecisionOperand badShift
where not isExcluded(badShift, Types1Package::exprShiftedbyNegativeOrGreaterPrecisionOperandQuery())
select badShift, badShift.getReason()
