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

from Loop loop
where
  not isExcluded(loop, Statements4Package::floatingPointLoopCountersQuery()) and
  exists(WhileStmt while |
    while.getCondition().getType() instanceof FloatType and
    loop = while
  )
  or
  exists(ForStmt for, Variable counter |
    isForLoopWithFloatingPointCounters(for, counter) and for = loop
  )
select loop, "Loop $@ has a floating-point type.", loop.getControllingExpr(), "counter"
