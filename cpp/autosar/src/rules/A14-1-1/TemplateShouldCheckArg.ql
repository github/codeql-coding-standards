/**
 * @id cpp/autosar/template-should-check-arg
 * @name A14-1-1: A template should check if a specific template argument is suitable for this template
 * @description Using certain types for template arguments can cause undefined behavour if the
 *              template uses the argument in an unchecked way that conflicts with the arguments'
 *              available characteristics.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a14-1-1
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Operator

class ClassWithTemplateArg extends Class {
  //has at least one template arg, only need to track one for alert value
  MemberVariable templateTypeMember;

  ClassWithTemplateArg() {
    this.getAMember() = templateTypeMember and
    templateTypeMember.getType() = this.getATemplateArgument()
  }

  MemberVariable getter() { result = templateTypeMember }
}

MemberFunction hasDefaultedMember(Class c) {
  result = c.getAMemberFunction() and
  result.isDefaulted()
}

class ClassThatShouldCheckTrivialMoveAssignable extends ClassWithTemplateArg {
  ClassThatShouldCheckTrivialMoveAssignable() { hasDefaultedMember(this) instanceof MoveOperator }
}

class ClassThatShouldCheckTrivialMoveConstructible extends ClassWithTemplateArg {
  ClassThatShouldCheckTrivialMoveConstructible() {
    hasDefaultedMember(this) instanceof MoveConstructor
  }
}

class ClassThatShouldCheckTrivialCopyAssignable extends ClassWithTemplateArg {
  ClassThatShouldCheckTrivialCopyAssignable() { hasDefaultedMember(this) instanceof CopyOperator }
}

class ClassThatShouldCheckTrivialCopyConstructible extends ClassWithTemplateArg {
  ClassThatShouldCheckTrivialCopyConstructible() {
    hasDefaultedMember(this) instanceof CopyConstructor
  }
}

class TrivialCopyConstructibleValueStaticAssert extends StaticAssert {
  TrivialCopyConstructibleValueStaticAssert() {
    this.getCondition()
        .(NameQualifiableElement)
        .getNameQualifier()
        .toString()
        .matches("is_trivially_copy_constructible<%")
  }
}

class TrivialCopyAssignableValueStaticAssert extends StaticAssert {
  TrivialCopyAssignableValueStaticAssert() {
    this.getCondition()
        .(NameQualifiableElement)
        .getNameQualifier()
        .toString()
        .matches("is_trivially_copy_assignable<%")
  }
}

class TrivialMoveConstructibleValueStaticAssert extends StaticAssert {
  TrivialMoveConstructibleValueStaticAssert() {
    this.getCondition()
        .(NameQualifiableElement)
        .getNameQualifier()
        .toString()
        .matches("is_trivially_move_constructible<%")
  }
}

class TrivialMoveAssignableValueStaticAssert extends StaticAssert {
  TrivialMoveAssignableValueStaticAssert() {
    this.getCondition()
        .(NameQualifiableElement)
        .getNameQualifier()
        .toString()
        .matches("is_trivially_move_assignable<%")
  }
}

from ClassWithTemplateArg c, string cond
where
  not isExcluded(c, TemplatesPackage::templateShouldCheckArgQuery()) and
  (
    //move assignable
    c instanceof ClassThatShouldCheckTrivialMoveAssignable and
    cond = "move assignable" and
    not exists(TrivialMoveAssignableValueStaticAssert s | s.getEnclosingElement() = c)
    or
    //move constructible
    c instanceof ClassThatShouldCheckTrivialMoveConstructible and
    cond = "move constructible" and
    not exists(TrivialMoveConstructibleValueStaticAssert s | s.getEnclosingElement() = c)
    or
    //copy assignable
    c instanceof ClassThatShouldCheckTrivialCopyAssignable and
    cond = "copy assignable" and
    not exists(TrivialCopyAssignableValueStaticAssert s | s.getEnclosingElement() = c)
    or
    //copy constructible
    c instanceof ClassThatShouldCheckTrivialCopyConstructible and
    cond = "copy constructible" and
    not exists(TrivialCopyConstructibleValueStaticAssert s | s.getEnclosingElement() = c)
  )
  or
  c instanceof TemplateClass and
  //any of the "should checks"
  (
    c instanceof ClassThatShouldCheckTrivialMoveAssignable or
    c instanceof ClassThatShouldCheckTrivialMoveConstructible or
    c instanceof ClassThatShouldCheckTrivialCopyAssignable or
    c instanceof ClassThatShouldCheckTrivialCopyConstructible
  ) and
  //with no static_assert's at all
  not exists(StaticAssert anyAssert | anyAssert.getEnclosingElement() = c) and
  cond = "copy/move assignable/constructible"
select c, "Class should check if template type is " + cond + " due to its member $@.",
  c.getter().getADeclarationEntry(), c.getter().getName()
