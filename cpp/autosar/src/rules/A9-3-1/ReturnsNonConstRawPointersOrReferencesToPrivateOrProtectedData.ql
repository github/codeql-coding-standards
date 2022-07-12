/**
 * @id cpp/autosar/returns-non-const-raw-pointers-or-references-to-private-or-protected-data
 * @name A9-3-1: Member functions shall not return non-const 'raw' pointers or references to private or protected
 * @description Member functions shall not return non-const 'raw' pointers or references to private
 *              or protected data owned by the class.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a9-3-1
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/partially-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.CommonTypes as CommonTypes
import semmle.code.cpp.dataflow.DataFlow

class AccessAwareMemberFunction extends MemberFunction {
  Class c;
  Type t;

  AccessAwareMemberFunction() {
    c = getDeclaringType() and
    // this optimization allows this query to run quickly
    // by only considering member functions where a reference
    // of the type we are interested in may occur.
    exists(CommonTypes::PointerOrReferenceType rt |
      rt = getType() and
      not rt.getBaseType().isConst()
    )
  }

  /**
   * Gets a `FieldAccess` within this method.
   */
  FieldAccess getAFieldAccess() {
    exists(FieldAccess fa, Field f |
      f = c.getAField() and
      fa.getTarget() = f and
      fa.getEnclosingFunction() = this and
      result = fa
    )
  }

  /**
   * Gets a `ReturnStmt` within this method
   */
  ReturnStmt getAReturnStmt() {
    exists(ReturnStmt rs |
      rs.getEnclosingFunction() = this and
      result = rs
    )
  }
}

from Class c, AccessAwareMemberFunction mf, FieldAccess a, ReturnStmt rs
where
  not isExcluded(c) and
  not isExcluded(mf,
    ClassesPackage::returnsNonConstRawPointersOrReferencesToPrivateOrProtectedDataQuery()) and
  // Find all of the methods within this class
  mf = c.getAMemberFunction() and
  // Select those which have a field access within them
  a = mf.getAFieldAccess() and
  // Select only those which also have a return statement
  rs = mf.getAReturnStmt() and
  // Exclude any public fields
  not a.getTarget().isPublic() and
  // select those which have dataflow between the usage and return statement
  DataFlow::localFlow(DataFlow::exprNode(a), DataFlow::exprNode(rs.getExpr()))
select mf,
  "Member function " + mf.getQualifiedName() +
    " $@ a non-const raw pointer or reference to a private or protected $@.", rs.getExpr(),
  "returns", a.getTarget(), "field"
