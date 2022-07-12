/**
 * @id cpp/autosar/member-function-const-if-possible
 * @name M9-3-3: A member function shall be made const where possible
 * @description Using `const` specifiers for member functions where possible prevents unintentional
 *              data modification (and therefore unintentional program behaviour).
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/m9-3-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SideEffect

/**
 * `Declaration` is declared in `Class` c
 * or any of c's parents
 */
predicate belongsToClass(Declaration m, Class c) {
  m.getDeclaringType() = c
  or
  exists(Class anyParent |
    m.getDeclaringType() = anyParent and
    anyParent.getADerivedClass+() = c
  )
}

/**
 * `MemberFunction`s that are not const
 */
class NonConstMemberFunction extends MemberFunction {
  NonConstMemberFunction() { not this.hasSpecifier("const") }
}

/**
 * `MemberFunction`s that are not const
 * and not `Constructor`s ect as const constructors are
 * not a thing in cpp
 * also not static because there is no `this` in
 * static `MemberFunction`
 */
class ConstMemberFunctionCandidate extends NonConstMemberFunction {
  ConstMemberFunctionCandidate() {
    //can't be const if already static
    not this.isStatic() and
    //leave compiler generateds and operators and constructors alone
    not this.isCompilerGenerated() and
    not this instanceof Constructor and
    not this instanceof Destructor and
    not this instanceof Operator and
    //less interested in MemberFunctions with no definition
    this.hasDefinition()
  }

  /**
   * A `MemberVariable` is modified in this `MemberFunction`
   * directly
   */
  predicate modifiesMemberData() {
    exists(VariableEffect e, NonStaticMemberVariable v |
      e.getTarget() = v and
      this = e.getEnclosingFunction() and
      belongsToClass(v, this.getDeclaringType())
    )
  }

  /**
   * Calls a `MemberFunction` that it owns that is nonconst
   */
  predicate callsNonConstOwnMember() {
    exists(NonConstMemberFunction f |
      //omit recursive functions
      not f = this and
      belongsToClass(f, this.getDeclaringType()) and
      f.getACallToThisFunction().getEnclosingFunction() = this
    )
  }

  /**
   * Calls any nonconst `MemberFunction` that its `MemberVariable`s own
   */
  predicate callsNonConstFromMemberVariable() {
    exists(NonConstMemberFunction f, MemberVariable m |
      belongsToClass(m, f.getDeclaringType()) and
      belongsToClass(f, m.getDeclaringType()) and
      f.getACallToThisFunction().getEnclosingFunction() = this
    )
  }

  /**
   * `ThisExpr`s that are on left hand side
   * of `AssignExpr`s
   * example: `*this = *i;`
   */
  predicate modifiesThis() { exists(AssignExprToThis e | e.getEnclosingFunction() = this) }
}

class AssignExprToThis extends AssignExpr {
  AssignExprToThis() {
    exists(ThisExpr t | this.getLValue().(PointerDereferenceExpr).getOperand() = t)
  }
}

/**
 * A nonstatic `MemberVariable`
 */
class NonStaticMemberVariable extends MemberVariable {
  NonStaticMemberVariable() { not this.isStatic() }
}

from ConstMemberFunctionCandidate f
where
  not isExcluded(f, ConstPackage::memberFunctionConstIfPossibleQuery()) and
  not f.modifiesMemberData() and
  not f.modifiesThis() and
  not f.callsNonConstOwnMember() and
  not f.callsNonConstFromMemberVariable() and
  not f.isOverride() and
  not f.isFinal()
select f, "Member function can be declared as const."
