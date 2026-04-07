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

abstract class MembersReturningObjectOrSubobject extends MemberFunction {
  string toString() { result = "Members returning object or subobject" }
}

class MembersReturningObject extends MembersReturningObjectOrSubobject {
  MembersReturningObject() {
    exists(ReturnStmt r, ThisExpr t |
      r.getEnclosingFunction() = this and
      (
        r.getAChild*() = t
        or
        exists(PointerDereferenceExpr p |
          p.getAChild*() = t and
          r.getAChild*() = p
        )
      ) and
      t.getActualType().stripType() = this.getDeclaringType()
    )
  }
}

class MembersReturningSubObject extends MembersReturningObjectOrSubobject {
  MembersReturningSubObject() {
    exists(ReturnStmt r, FieldSubObjectDeclaration field |
      r.getEnclosingFunction() = this and
      (
        r.getAChild*() = field.(Field).getAnAccess()
        or
        exists(PointerDereferenceExpr p |
          p.getAChild*() = field.(Field).getAnAccess() and
          r.getAChild*() = p
        )
      ) and
      field.(Field).getDeclaringType() = this.getDeclaringType()
    )
  }
}

predicate relevantTypes(Type a, Type b) {
  exists(MembersReturningObject f, MemberFunction overload |
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
    not this.hasSpecifier("const")
    or
    //const-lvalue-ref-qualified
    this.isLValueRefQualified() and
    this.hasSpecifier("const") and
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

/**
 * Fields that are not reference type can be subobjects
 */
class FieldSubObjectDeclaration extends Declaration {
  FieldSubObjectDeclaration() {
    not this.getADeclarationEntry().getType() instanceof ReferenceType and
    this instanceof Field
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
