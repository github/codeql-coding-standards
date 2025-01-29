/**
 * @id cpp/autosar/assignment-operator-return-this
 * @name A13-2-1: An assignment operator shall return a reference to 'this'
 * @description An assignment operator shall return a reference to 'this'.  Returning a type T& from
 *              an assignment operator is consistent with the C++ Standard Library.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a13-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator
import semmle.code.cpp.dataflow.DataFlow

predicate returnsThisPointer(UserAssignmentOperator o) {
  exists(PointerDereferenceExpr p, ThisExpr t, ReturnStmt r |
    r.getEnclosingFunction() = o and
    p.getAnOperand() = t and
    DataFlow::localExprFlow(p, r.getExpr())
  ) and
  not o.getType().isDeeplyConst()
}

from UserAssignmentOperator o
where
  not isExcluded(o, OperatorInvariantsPackage::assignmentOperatorReturnThisQuery()) and
  not returnsThisPointer(o)
select o, "User-defined assignment operator $@ does not return *this", o,
  " user defined assignment operator"
