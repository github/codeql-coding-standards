/**
 * @id cpp/misra/improperly-provided-special-member-functions
 * @name RULE-15-0-1: Special member functions shall be provided appropriately
 * @description Incorrect provision of special member functions can lead to unexpected or undefined
 *              behavior when objects of the class are copied, moved, or destroyed.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/misra/id/rule-15-0-1
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import AnalyzableClass

predicate isCopyEnabled(AnalyzableClass c) {
  c.moveConstructible() and
  not c.moveAssignable() and
  c.copyConstructible() and
  not c.copyAssignable()
  or
  c.moveConstructible() and
  c.moveAssignable() and
  c.copyConstructible() and
  c.copyAssignable()
}

predicate isMoveOnly(AnalyzableClass c) {
  c.moveConstructible() and
  not c.moveAssignable() and
  not c.copyConstructible() and
  not c.copyAssignable()
  or
  c.moveConstructible() and
  c.moveAssignable() and
  not c.copyConstructible() and
  not c.copyAssignable()
}

predicate isUnmovable(AnalyzableClass c) {
  not c.moveConstructible() and
  not c.moveAssignable() and
  not c.copyConstructible() and
  not c.copyAssignable()
}

predicate isValidCategory(AnalyzableClass c) {
  isCopyEnabled(c) or
  isMoveOnly(c) or
  isUnmovable(c)
}

string specialMemberName(TSpecialMember f) {
  f = TCopyConstructor() and result = "copy constructor"
  or
  f = TMoveConstructor() and result = "move constructor"
  or
  f = TCopyAssignmentOperator() and result = "copy assignment operator"
  or
  f = TMoveAssignmentOperator() and result = "move assignment operator"
}

predicate violatesCustomizedMoveOrCopyRequirements(AnalyzableClass c, string reason) {
  not c.isCustomized(TDestructor()) and
  exists(string concatenated |
    concatenated =
      strictconcat(TSpecialMember f |
        not f = TDestructor() and
        c.isCustomized(f)
      |
        specialMemberName(f), ", "
      ) and
    reason = "has customized " + concatenated + ", but does not customize the destructor."
  )
}

private predicate undeclaredMoveException(AnalyzableClass c) {
  isCopyEnabled(c) and
  (
    if c.copyAssignable()
    then
      // A copy-assignable class may have an undeclared move constructor.
      not c.declaresMoveConstructor() and
      not c.declaresMoveAssignmentOperator()
    else
      // A copy-enabled class may have an undeclared move constructor.
      not c.declaresMoveConstructor()
  )
}

predicate violatesCustomizedDestructorRequirements(AnalyzableClass c, string reason) {
  // This is is simplified from the exact MISRA spec in order to more closely enforce the general
  // idea that, if you customize the destructor, you generally need to customize the other special
  // member functions (e.g., ISO C++ Core Guidelines C.21 and C.22).
  //
  // The MISRA specification is subtle and arguably ambiguous. In our interpretation of the rules,
  // bullet 2 sentence 2 is deemed to only apply to move-only classes, otherwise it would conflict
  // with bullet 3 sentence 2. We do not strictly need to enforce any additional constraints on
  // bullet 3 sentence 2; all compliant copy-assignable classes must be copy-enabled.
  //
  // Here is a logical derivation that shows our logic is equivalent to the MISRA spec for classes
  // that fall into one of the compliant categories. For classes outside of those categories, we
  // essentially enforce C.21 and C.22 from the ISO C++ Core Guidelines.
  //
  // ```
  // -- For all rules, assume hasCustomizedDestructor(class).
  // isMoveOnly(class)         -> hasCustomMoveConstructor(class)
  // isMoveOnly(class) &&
  //   isMoveAssignable(class) -> hasCustomMoveConstructor(class) && hasCustomMoveAssignment(class)
  // isCopyEnabled(class)      -> hasCustomCopyConstructor(class) && (hasCustomMoveConstructor(class)
  //                           || ~isMoveConstructorDeclared(class))
  // isCopyAssignable(class)   -> hasCustomCopyAssignment(class)
  //                           && (   hasCustomMoveConstructor(class) && hasCustomMoveAssignment(class)
  //                               || ~isMoveConstructorDeclared(class) && ~isMoveAssignmentDeclared(class))
  //
  // -- Invert
  // hasCustomMoveConstructor(c) -> isMoveOnly(c)
  //                             || isMoveAssignable(c)
  //                             || (isCopyEnabled(c) && ~isMoveConstructorDeclared(c))
  //                             || (isCopyAssignable(c) && ~isMoveConstructorDeclared(c)
  //                                                     && ~isMoveAssignmentDeclared(c))
  //
  // hasCustomMoveAssignmentOperator(c) -> (isMoveOnly(class) && isMoveAssignable(c))
  //                                    || isCopyAssignable(c) && ~isMoveConstructorDeclared(c)
  //                                                           && ~isMoveAssignmentDeclared(c))
  //
  // hasCustomCopyConstructor(c) -> isCopyEnabled(c)
  //                             || isCopyAssignable(c)
  //
  // hasCustomCopyAssignmentOperator(c) -> isCopyAssignable(c);
  //
  // -- Intermediate statements derived from table
  // isCopyAssignable(c) -> isMoveAssignable(c)
  // isMoveAssignable(c) -> isMoveConstructible(c)
  // isCopyEnabled(c) || isCopyAssignable(c) -> isCopyConstructible(c)
  // isMoveOnly(c) || isMoveAssignable(c) || isCopyEnabled(c) || isCopyAssignable(c) -> isMoveConstructible(c)
  //
  // -- Simplify
  // hasCustomMoveConstructor(c)        -> isMoveConstructible(c)
  //                                    || (isCopyEnabled(c) && ~isMoveConstructorDeclared(c))
  //                                    || (isCopyAssignable(c) && ~isMoveConstructorDeclared(c) && ~isMoveAssignmentDeclared(c))
  // hasCustomMoveAssignmentOperator(c) -> isMoveAssignable(c)
  //                                    || isCopyAssignable(c) && (~isMoveConstructorDeclared(c) && ~isMoveAssignmentDeclared(c))
  // hasCustomCopyConstructor(c)        -> isCopyConstructible(c)
  // hasCustomCopyAssignmentOperator(c) -> isCopyAssignable(c)
  //
  // -- Extract exceptional cases
  // Exception1(class) :- isCopyEnabled(c) && ~isMoveConstructorDeclared(c)
  // Exception2(class) :- isCopyAssignable(c) && ~isMoveConstructorDeclared(c) && ~isMoveAssignmentDeclared(c)
  //
  // -- Simplify
  // hasCustomMoveConstructor(class)    -> isMoveConstructible(c) || Exception1(c) || Exception2(c)
  // hasCustomMoveAssignmentOperator(c) -> isMoveAssignable(c) || Exception2(c)
  // hasCustomCopyConstructor(c)        -> isCopyConstructible(c)
  // hasCustomCopyAssignmentOperator(c) -> isCopyAssignable(c);
  // ```
  c.isCustomized(TDestructor()) and
  (
    c.moveConstructible() and
    not c.isCustomized(TMoveConstructor()) and
    not undeclaredMoveException(c) and
    reason = "has customized the destructor, but does not customize the move constructor."
    or
    c.moveAssignable() and
    not undeclaredMoveException(c) and
    not c.isCustomized(TMoveAssignmentOperator()) and
    reason = "has customized the destructor, but does not customize the move assignment operator."
    or
    c.copyConstructible() and
    not c.isCustomized(TCopyConstructor()) and
    reason = "has customized the destructor, but does not customize the copy constructor."
    or
    c.copyAssignable() and
    not c.isCustomized(TCopyAssignmentOperator()) and
    reason = "has customized the destructor, but does not customize the copy assignment operator."
  )
}

predicate isPublicBase(AnalyzableClass c) {
  exists(ClassDerivation d |
    d.getBaseClass() = c and
    d.hasSpecifier("public")
  )
}

predicate satisfiesInheritanceRequirements(AnalyzableClass c) {
  not isPublicBase(c)
  or
  isUnmovable(c) and
  c.getDestructor().isPublic() and
  c.getDestructor().isVirtual()
  or
  c.getDestructor().isProtected() and
  not c.getDestructor().isVirtual()
}

from AnalyzableClass c, string message
where
  not isExcluded(c, Classes3Package::improperlyProvidedSpecialMemberFunctionsQuery()) and
  (
    not isValidCategory(c) and
    message = "does not fall into a valid category (isUnmovable, move-only, or copy-enabled)."
    or
    violatesCustomizedMoveOrCopyRequirements(c, message)
    or
    violatesCustomizedDestructorRequirements(c, message)
    or
    not satisfiesInheritanceRequirements(c) and
    message = "violates inheritance requirements for special member functions."
  )
select c, "Class '" + c.getName() + "' " + message
