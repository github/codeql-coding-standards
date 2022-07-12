/**
 * @id cpp/autosar/function-return-automatic-var-condition
 * @name M7-5-1: A function shall not return a reference or a pointer to an automatic variable (including parameters)
 * @description Functions that return a reference or a pointer to an automatic variable (including
 *              parameters) potentially lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m7-5-1
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from ReturnStmt rs, StackVariable auto, Function f, VariableAccess va, string returnType
where
  f = rs.getEnclosingFunction() and
  (
    f.getType() instanceof ReferenceType and va = rs.getExpr() and returnType = "reference"
    or
    f.getType() instanceof PointerType and
    va = rs.getExpr().(AddressOfExpr).getOperand() and
    returnType = "pointer"
  ) and
  auto = va.getTarget() and
  not auto.isStatic() and
  not f.isCompilerGenerated() and
  not auto.getType() instanceof ReferenceType
select rs, "The $@ returns a " + returnType + "to an $@ variable", f, f.getName(), auto, "automatic"
