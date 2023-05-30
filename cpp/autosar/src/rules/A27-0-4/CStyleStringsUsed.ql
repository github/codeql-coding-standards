/**
 * @id cpp/autosar/c-style-strings-used
 * @name A27-0-4: C-style strings shall not be used
 * @description C-style strings can be difficult to use correctly so std::string should be
 *              preferred.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a27-0-4
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow

class InstanceOfCStyleString extends Expr {
  InstanceOfCStyleString() {
    this instanceof StringLiteral
    or
    exists(FunctionCall fc |
      fc.getTarget().getName() = "c_str" and
      fc = this
    )
  }
}

from InstanceOfCStyleString cs, Expr e
where
  not isExcluded(cs, StringsPackage::cStyleStringsUsedQuery()) and
  (
    e = any(Variable v).getAnAssignedValue()
    or
    e = any(FunctionCall fc).getArgument(_) and
    e.getUnspecifiedType().(PointerType).getBaseType*() instanceof CharType
  ) and
  DataFlow::localFlow(DataFlow::exprNode(cs), DataFlow::exprNode(e)) and
  not cs = any(LocalVariable lv | lv.getName() = "__func__").getInitializer().getExpr()
select cs, "Usage of C-style string in $@.", e, "expression"
