/**
 * @id cpp/autosar/const-member-function-returns-non-const-pointer
 * @name M9-3-1: Const member functions shall not return non-const pointers/references to class-data
 * @description Returning references to class-data from `const` member functions is inconsistent
 *              with developer expectations because it allows modification of state of an object
 *              that was expected to be overall `const`.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m9-3-1
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import semmle.code.cpp.dataflow.DataFlow

class ReferenceTypeWithNonConstBaseType extends ReferenceType {
  ReferenceTypeWithNonConstBaseType() { not this.getBaseType().isConst() }
}

class PointerTypeWithNonConstBaseType extends PointerType {
  PointerTypeWithNonConstBaseType() { not this.getBaseType().isConst() }
}

class ConstMemberFunctionWithRetNonConst extends ConstMemberFunction {
  string returntype;

  ConstMemberFunctionWithRetNonConst() {
    //returns non-const ref or pointer
    this.getType() instanceof ReferenceTypeWithNonConstBaseType and
    returntype = "reference"
    or
    this.getType() instanceof PointerTypeWithNonConstBaseType and
    returntype = "pointer"
  }

  string getReturnTypeCategory() { result = returntype }
}

from ConstMemberFunctionWithRetNonConst fun, Locatable f
where
  not isExcluded(fun, ConstPackage::constMemberFunctionReturnsNonConstPointerQuery()) and
  exists(ReturnStmt ret |
    ret.getEnclosingFunction() = fun and
    (
      f.(MemberVariable).getDeclaringType() = fun.getDeclaringType() and
      DataFlow::localExprFlow(f.(MemberVariable).getAnAccess(), ret.getExpr())
      or
      DataFlow::localExprFlow(f.(ThisExpr), ret.getExpr())
    )
  )
select fun, "Const member function returns a " + fun.getReturnTypeCategory() + " to class data $@.",
  f, f.toString()
