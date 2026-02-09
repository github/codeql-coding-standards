/**
 * @id cpp/autosar/invalid-function-return-type
 * @name A7-5-1: Function shall not return a reference or pointer to parameter passed by reference to const
 * @description A function that returns a reference or a pointer to parameter that is by reference
 *              to const can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-5-1
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow

from Parameter p, ReturnStmt ret
where
  not isExcluded(p, FunctionsPackage::invalidFunctionReturnTypeQuery()) and
  p.getUnderlyingType().isDeeplyConst() and
  p.getType() instanceof DerivedType and
  p.getFunction().getType().stripTopLevelSpecifiers() instanceof DerivedType and
  DataFlow::localFlow(DataFlow::parameterNode(p), DataFlow::exprNode(ret.getExpr()))
select ret,
  "Function " + p.getFunction().getName() +
    " returns a reference or a pointer to $@ that is passed by reference to const.", p, "parameter"
