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
      (not exists(access.getQualifier()) or access.getQualifier() instanceof ThisExpr) and
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

predicate relevantFunctions(Function a, Function b) {
  a instanceof MembersReturningObjectOrSubobject and
  a.getAnOverload() = b
}

class AppropriatelyQualified extends MemberFunction {
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
      FunctionEquivalence<TypesCompatibleConfig, relevantFunctions/2>::equalParameterTypes(this,
        overload)
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
