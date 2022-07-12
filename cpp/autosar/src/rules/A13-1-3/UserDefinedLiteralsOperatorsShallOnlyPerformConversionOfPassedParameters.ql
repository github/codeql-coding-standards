/**
 * @id cpp/autosar/user-defined-literals-operators-shall-only-perform-conversion-of-passed-parameters
 * @name A13-1-3: User defined literals operators shall only perform conversion of passed parameters
 * @description User defined literals operators are expected to convert passed parameters and
 *              otherwise lead to unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a13-1-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.autosar
import codingstandards.cpp.UserDefinedLiteral
import codingstandards.cpp.SideEffect

from UserDefinedLiteral udl, Expr retExpr
where
  not isExcluded(udl,
    SideEffects2Package::userDefinedLiteralsOperatorsShallOnlyPerformConversionOfPassedParametersQuery()) and
  retExpr = udl.getBlock().getAStmt().(ReturnStmt).getExpr() and
  not TaintTracking::localTaint(DataFlow::parameterNode(udl.getAParameter()),
    DataFlow::exprNode(retExpr))
select udl,
  "User defined literal operator returns $@, which is not converted from a passed parameter",
  retExpr, "expression"
