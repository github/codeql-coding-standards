/**
 * @id c/cert/floating-point-loop-counters
 * @name FLP30-C: Do not use floating-point variables as loop counters
 * @description Loop counters should not use floating-point variables to keep code portable.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/cert/id/flp30-c
 *       maintainability
 *       readability
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Loops

/*
 *  A variable that is increased or decreased by a fixed amount on each iteration.
 */

class InductionVariable extends Variable {
  Loop loop;
  Expr update;

  InductionVariable() {
    update.getParent+() = loop and
    (
      update.(AssignArithmeticOperation).getRValue().isConstant() and
      update.(AssignArithmeticOperation).getLValue() = this.getAnAccess()
      or
      exists(BinaryArithmeticOperation binop |
        update.(Assignment).getLValue() = this.getAnAccess() and
        update.(Assignment).getRValue() = binop and
        binop.getAnOperand() = this.getAnAccess() and
        binop.getAnOperand().isConstant()
      )
      or
      update.(CrementOperation).getOperand() = this.getAnAccess()
    )
  }
}

from Loop loop, InductionVariable loopCounter, ComparisonOperation comparison
where
  not isExcluded(loop, Statements4Package::floatingPointLoopCountersQuery()) and
  loop.getControllingExpr() = comparison and
  comparison.getAnOperand() = loopCounter.getAnAccess() and
  loopCounter.getType() instanceof FloatingPointType
select loop, "Loop using a $@ of type floating-point.", loopCounter, "loop counter"
