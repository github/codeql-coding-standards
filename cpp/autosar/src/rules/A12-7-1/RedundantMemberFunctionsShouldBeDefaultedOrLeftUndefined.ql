/**
 * @id cpp/autosar/redundant-member-functions-should-be-defaulted-or-left-undefined
 * @name A12-7-1: Redundant special member functions should be defaulted or left undefined
 * @description If the behavior of a user-defined special member function is identical to implicitly
 *              defined special member function, then it shall be defined '=default' or be left
 *              undefined.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a12-7-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class

/*
 *  This query looks at the common conventions for defining special member
 *  functions and looks at the structural equivalence for deciding if a special
 *  member function is redundant. It does not try to introspect, for example,
 *  the expressions passed to initializers, only that, all of the initializers
 *  are used. Further, this query assumes any `noexcept` functions are not
 *  redundant since that is not implicit in the default behavior.
 */

class NonDefaultedNoExceptUserDefinedSpecialMemberFunction extends UserDefinedSpecialMemberFunction {
  NonDefaultedNoExceptUserDefinedSpecialMemberFunction() { not isNoExcept() and not isDefaulted() }
}

abstract class RedundantSpecialMemberFunction extends UserDefinedSpecialMemberFunction { }

abstract class RedundantNonDefaultNoExceptSpecialMemberFunction extends RedundantSpecialMemberFunction,
  NonDefaultedNoExceptUserDefinedSpecialMemberFunction { }

class RedundantCopySpecialMemberFunction extends RedundantNonDefaultNoExceptSpecialMemberFunction,
  CopyConstructor {
  RedundantCopySpecialMemberFunction() {
    // a copy function is redundant if
    // 1) it has a vacuous body
    hasVacuousBody() and
    // 2) For each base class, it calls the copy constructor belonging to that class
    forall(Class c | c = this.getDeclaringType().getABaseClass() |
      exists(ConstructorBaseInit ci |
        // Require that the initializer is the one from the base class and that
        // it is a copy constructor. We do not examine if the argument to the
        // copy constructor is correct.
        ci = this.getAnInitializer() and
        ci.getTargetType() = c and
        ci.getTarget() instanceof CopyConstructor
      )
    ) and
    // 3) Also, every field is initialized -- if one is left out, this, for
    //    example, would count as a non-defaulted field
    forall(Field f, Class c |
      c = this.getDeclaringType() and
      f = c.getAField()
    |
      exists(ConstructorFieldInit fi |
        fi = this.getAnInitializer() and
        fi.getTarget() = f
      )
    )
  }
}

class RedundantMoveSpecialMemberFunction extends RedundantNonDefaultNoExceptSpecialMemberFunction,
  MoveConstructor {
  RedundantMoveSpecialMemberFunction() {
    // a move function is redundant if
    // 1) it has a vacuous body
    hasVacuousBody() and
    // 2) it calls a target initializer for each member of the class. Also, it
    //    should call the constructor's copy constructor.
    forall(Class c | c = this.getDeclaringType().getABaseClass() |
      exists(ConstructorBaseInit ci |
        ci = this.getAnInitializer() and
        ci.getTarget() instanceof MoveConstructor
      )
    ) and
    // 3) Also, every field is initialized. Typically this would be with
    //    field(std::move(field)) but we don't look beyond ensuring each field
    //    is initialized.
    forall(Field f, Class c |
      c = this.getDeclaringType() and
      f = c.getAField()
    |
      exists(ConstructorFieldInit fi |
        fi = this.getAnInitializer() and
        fi.getTarget() = f
      )
    )
  }
}

class RedundantConstructorSpecialMemberFunction extends RedundantNonDefaultNoExceptSpecialMemberFunction,
  Constructor {
  RedundantConstructorSpecialMemberFunction() {
    // 1) The constructor should be not one of the other special types of
    //    constructors
    not (
      this instanceof CopyConstructor or
      this instanceof MoveConstructor
    ) and
    // 2) it should have a vacuous body
    hasVacuousBody() and
    // 3) There should not be any arguments
    this.getNumberOfParameters() = 0 and
    // 4) That there are NO fields being initialized
    count(ConstructorFieldInit fi | fi = getAnInitializer()) = 0 and
    // 5) For each base class, we call a no arg version of the base class constructor
    forall(Class c | c = getDeclaringType().getABaseClass() |
      exists(ConstructorBaseInit b |
        b = getAnInitializer() and
        b.getTargetType() = c and
        b.getTarget().getNumberOfParameters() = 0
      )
    )
  }
}

class RedundantDestructorSpecialMemberFunction extends RedundantSpecialMemberFunction, Destructor {
  RedundantDestructorSpecialMemberFunction() {
    // The only requirement is that the body is vacuous because a destructor
    // cannot have parameters and does not call initializers.
    hasVacuousBody()
  }
}

class RedundantCopyAssignmentOperatorSpecialMemberFunction extends RedundantNonDefaultNoExceptSpecialMemberFunction,
  CopyAssignmentOperator {
  RedundantCopyAssignmentOperatorSpecialMemberFunction() {
    // The copy (and move) assignment operator is especially hard to tell if it
    // is the same behavior as the default constructor. For our purposes we use
    // a simple two part heuristic.
    //
    // First, a common pattern is to "short circuit" the copy assignment
    // operator by providing an empty body. Like so:
    //
    //    `H &operator=(H o);`
    //
    // Such an implementation can never be redundant, even if there are no
    // fields. Thus we require at least one statement even if it was compiler
    // generated to be possibly redundant.
    count(getEntryPoint().(BlockStmt).getAStmt()) > 0 and
    // Second, a "shallow" copy of the object is essentially assignment to all
    // of the fields. There are many ways to do this, so for our purposes we
    // just look for bodies where only assignments are done and the number of
    // assignments matches the number of fields.
    exists(int nFields, int nAssignments, int nStatements |
      nFields = count(this.getDeclaringType().getAField()) and
      nAssignments = count(getEntryPoint().(BlockStmt).getAStmt().(ExprStmt).getExpr().(AssignExpr)) and
      nStatements =
        count(Stmt s |
          s = getEntryPoint().(BlockStmt).getAStmt() and
          not s.isCompilerGenerated() and
          not s instanceof ReturnStmt // we are not interested in return statements since there must be one
        )
    |
      nFields = nAssignments and
      nAssignments = nStatements
    )
  }
}

class RedundantMoveAssignmentOperatorSpecialMemberFunction extends RedundantNonDefaultNoExceptSpecialMemberFunction,
  MoveAssignmentOperator {
  RedundantMoveAssignmentOperatorSpecialMemberFunction() {
    // The move (and copy) assignment operator is especially hard to tell if it
    // is the same behavior as the default constructor. For our purposes we use
    // a simple two part heuristic.
    //
    // First, a common pattern is to "short circuit" the move assignment
    // operator by providing an empty body. Like so:
    //
    //    `H &operator=(H &&h);`
    //
    // Such an implementation can never be redundant, even if there are no
    // fields. Thus we require at least one statement even if it was compiler
    // generated to be possibly redundant.
    count(getEntryPoint().(BlockStmt).getAStmt()) > 0 and
    // Second, another reliable thing we can check is to see if the number of
    // fields and the number of non-return statements is different. For an
    // object with N fields, there should be at least N  non-return statements
    // within the function. Thus, an object with LESS than this number cannot be
    // redundant.
    exists(int nFields, int nStatements |
      nFields = count(this.getDeclaringType().getAField()) and
      nStatements =
        count(Stmt s |
          s = getEntryPoint().(BlockStmt).getAStmt() and
          not s.isCompilerGenerated() and
          not s instanceof ReturnStmt
        )
    |
      nStatements >= nFields
    )
  }
}

from RedundantSpecialMemberFunction e
where
  not isExcluded(e, ClassesPackage::redundantMemberFunctionsShouldBeDefaultedOrLeftUndefinedQuery()) and
  not e.isCompilerGenerated() and
  not e.isDefaulted()
select e,
  "Non-defaulted special member function " + e.getQualifiedName() +
    " may be the same as the one generated by the compiler."
