/**
 * @id cpp/misra/member-functions-refqualified
 * @name RULE-6-8-4: Member functions returning references to their object should be refqualified appropriately
 * @description Member functions that return references to temporary objects (or subobjects) can
 *              lead to dangling pointers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-8-4
 *       correctness
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.Compatible
import codingstandards.cpp.Operator
import codingstandards.cpp.types.Pointers
import codingstandards.cpp.lifetimes.CppObjects

class MembersReturningPointerOrRef extends MemberFunction {
  MembersReturningPointerOrRef() { this.getType() instanceof PointerLikeType }
}

abstract class MembersReturningObjectOrSubobject extends MembersReturningPointerOrRef {
  string toString() { result = "Members returning object or subobject" }
}

/**
 * Members that have an explicit `this` access within their return statement.
 */
class MembersReturningObject extends MembersReturningObjectOrSubobject {
  MembersReturningObject() {
    exists(ReturnStmt r, ThisExpr t |
      r.getEnclosingFunction() = this and
      //return `this`
      r.getAChild() = t and
      t.getActualType().stripType() = this.getDeclaringType()
    )
  }
}

/**
 * Members that have an explicit subobject access within their return statement.
 *
 * Specifically, this captures when the return is a reference or pointer
 * to a subobject.
 */
class MembersReturningSubObject extends MembersReturningObjectOrSubobject {
  MembersReturningSubObject() {
    exists(ReturnStmt r, FieldAccess access, Expr e |
      r.getEnclosingFunction() = this and
      (
        //subobject returned by address
        r.getAChild() = access.getParent() and
        e = getASubobjectAccessOf(access) and
        access.getParent() instanceof AddressOfExpr
        or
        //reference to subobject returned
        r.getAChild() = e and
        e = getASubobjectAccessOf(access) and
        this.getType() instanceof ReferenceType
      )
    )
  }
}

predicate relevantTypes(Type a, Type b) {
  exists(MembersReturningObjectOrSubobject f, MemberFunction overload |
    f.getAnOverload() = overload and
    exists(int i |
      f.getParameter(i).getType() = a and
      overload.getParameter(i).getType() = b
    )
  )
}

class AppropriatelyQualified extends MembersReturningObjectOrSubobject {
  AppropriatelyQualified() {
    //non-const-lvalue-ref-qualified
    this.isLValueRefQualified() and
    this.getType().(PointerLikeType).pointsToNonConst()
    or
    //const-lvalue-ref-qualified
    this.isLValueRefQualified() and
    this.getType().(PointerLikeType).pointsToConst() and
    //and overload exists that is rvalue-ref-qualified
    exists(MemberFunction overload |
      this.getAnOverload() = overload and
      overload.isRValueRefQualified() and
      //and has same param list
      forall(int i | exists([this, overload].getParameter(i)) |
        TypeEquivalence<TypesCompatibleConfig, relevantTypes/2>::equalTypes(this.getParameter(i)
              .getType(), overload.getParameter(i).getType())
      )
    )
  }
}

class DefaultedAssignmentOperator extends AssignmentOperator {
  DefaultedAssignmentOperator() { this.isDefaulted() }
}

from MembersReturningObjectOrSubobject f
where
  not isExcluded(f, Declarations5Package::memberFunctionsRefqualifiedQuery()) and
  not f instanceof AppropriatelyQualified and
  not f instanceof DefaultedAssignmentOperator
select f, "Member function is not properly ref qualified."
