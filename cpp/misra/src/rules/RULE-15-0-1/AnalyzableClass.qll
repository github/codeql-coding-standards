/**
 * Provides predicates and classes to perform a precursor analysis of which classes the rule can
 * potentially analyze, or should be excluded and instead selected by the audit query.
 *
 * For example, the class `AnalyzableClass` resolves all of the special member functions that we
 * must have in order to determine rule compliance.
 *
 * Part of what this module does is perform a very approximate analysis of which classes will
 * produce a value of true in `std::is_(copy|move)_(constructible|assignable)_v`.
 *
 * Fully predicting these standard type traits requires performing a very thorough overload
 * resolution analysis, including value category propagation and reference binding and user defined
 * conversion operators and standard conversions and promotions and ranking viable candidates and
 * properly handling ambiguous overloads.
 */

import cpp

/**
 * For `std::is_(copy|move)_(constructible|assignable)_v` to return true for a given class, the
 * member must exist, it must not be deleted, and it must be publicly accessible.
 *
 * This is a very coarse approximation of true behavior of the standard type traits.
 */
private predicate isUsable(MemberFunction f) {
  not f.isDeleted() and
  f.isPublic()
}

/**
 * Holds if the member function `f` has been "customized" by the user, e.g., they explicitly wrote
 * the implementation of the function.
 */
private predicate isMemberCustomized(MemberFunction f) {
  exists(f.getDefinition()) and
  not f.isDefaulted() and
  not f.isDeleted() and
  not f.isCompilerGenerated()
}

/**
 * Holds if the user declared the member function `f`, as opposed to it being implicitly declared
 * by the compiler.
 *
 * Note that `T(T&&) = default` and `T(T&&) = delete` are both user declared. This is not to be
 * confused with "user defined."
 */
private predicate isUserDeclared(MemberFunction f) { not f.isCompilerGenerated() }

/**
 * Holds if the implicit move constructor or move assignment operator of the class `c` will not be
 * declared.
 *
 * See [class.copy]/8 and [class.copy]
 */
private predicate implicitMoveIsSuppressed(Class c) {
  isUserDeclared(c.getAConstructor().(CopyConstructor))
  or
  isUserDeclared(c.getAMemberFunction().(CopyAssignmentOperator))
  or
  isUserDeclared(c.getDestructor())
}

/**
 * Returns the move constructor of the class `c` if it exists, or the copy constructor if it does
 * not exist and the implicit definition was suppressed by the compiler.
 */
private Constructor getMoveConstructor(Class c) {
  if
    not exists(MoveConstructor mc | mc = c.getAConstructor() and isUserDeclared(mc)) and
    implicitMoveIsSuppressed(c)
  then result = c.getAConstructor().(CopyConstructor)
  else result = c.getAConstructor().(MoveConstructor)
}

/**
 * Returns the move assignment operator of the class `c` if it exists, or the copy assignment
 * operator if it does not exist and the implicit definition was suppressed by the compiler.
 */
private Operator getMoveAssign(Class c) {
  if
    not exists(MoveAssignmentOperator mc | mc = c.getAMemberFunction() and isUserDeclared(mc)) and
    implicitMoveIsSuppressed(c)
  then result = c.getAMemberFunction().(CopyAssignmentOperator)
  else result = c.getAMemberFunction().(MoveAssignmentOperator)
}

/**
 * The types of special member functions that the `AnalyzableClass` tracks and analyzes.
 */
newtype TSpecialMember =
  TMoveConstructor() or
  TMoveAssignmentOperator() or
  TCopyConstructor() or
  TCopyAssignmentOperator() or
  TDestructor()

/**
 * A class for which we can see all special member functions, including implicitly declared ones,
 * and therefore we can attempt to analyze it in the current rule.
 *
 * If one of the special member functions cannot be found, we cannot know if it is missing because
 * it should not have been generated, or if EDG did not emit a definition for it. For instance, EDG
 * may not generate these functions if they are trivial, or if they are delete, or not ODR used. We,
 * the authors of this project, do not know the exact conditions we have to consider in this case.
 *
 * Determining for ourselves whether a certain constructor would be implicitly declared, and with
 * what signature, and whether it is deleted, requires implementing a significant portion of the C++
 * language rules regarding special member function generation, including a significant portion of
 * C++ overload resolution rules which are non-trivial.
 *
 * Therefore we must find a definition for each special member in the database to proceed. The only
 * exception we allow is certain missing `MoveConstructor` or `MoveAssignmentOperator` members; if
 * the class defines copy operations or the destructor, we expect these to be missing, and typically
 * this means the corresponding copy operation acts in place of the equivalent move.
 *
 * The last difficulty in analysis that this class attempts to handle is the values of the type
 * traits `std::is_(copy|move)_(constructible|assignable)`. These type traits are defined as true if
 * certain C++ expressions, such as `T(declval<T>())` or `declval<T>() = declval<T>()`, are
 * well-formed. We cannot correctly determine this in all cases without implementing a significant
 * portion of the C++ language rules for reference binding and overload resolution.
 *
 * To handle these type traits, we take a very rough approximation. If the corresponding special
 * member function is public and not deleted, then we assume the type trait will evaluate to true.
 * We also handle the case where a user declared copy operation suppresses the implicit move
 * operations, which typically means overload resolution selects the copy operation. (This is not
 * the case when the move operations are declared as deleted). We handle this by treating the copy
 * operation as effectively acting in place of the move operation for the purposes of evaluating
 * the type traits.
 */
class AnalyzableClass extends Class {
  CopyConstructor copyCtor;
  // The move constructor may be suppressed, and the copy constructor may be used during moves.
  Constructor moveCtor;
  CopyAssignmentOperator copyAssign;
  // The move assignment operator may be suppressed, and the copy assignment operator may be used during moves.
  Operator moveAssign;
  Destructor dtor;

  AnalyzableClass() {
    copyCtor = this.getAConstructor() and
    moveCtor = getMoveConstructor(this) and
    copyAssign = this.getAMemberFunction() and
    moveAssign = getMoveAssign(this) and
    dtor = this.getDestructor()
  }

  /**
   * Holds `std::is_move_constructible_v<T>` is likely true for this class.
   *
   * Specifically this holds if there's a non-deleted public move constructor available for this
   * class, or if there is a non-deleted public copy constructor that acts as the move constructor.
   */
  predicate moveConstructible() { isUsable(moveCtor) }

  /**
   * Holds `std::is_copy_constructible_v<T>` is likely true for this class.
   *
   * Specifically this holds if there's a non-deleted public copy constructor available for this
   * class.
   */
  predicate copyConstructible() { isUsable(copyCtor) }

  /**
   * Holds `std::is_move_assignable_v<T>` is likely true for this class.
   *
   * Specifically this holds if there's a non-deleted public move assignment operator available for
   * this class, or if there is a non-deleted public copy assignment operator that acts as the move
   * assignment operator.
   */
  predicate moveAssignable() { isUsable(moveAssign) }

  /**
   * Holds `std::is_copy_assignable_v<T>` is likely true for this class.
   *
   * Specifically this holds if there's a non-deleted public copy assignment operator available for
   * this class.
   */
  predicate copyAssignable() { isUsable(copyAssign) }

  /**
   * Holds if the given special member function `s` is customized for this class.
   *
   * For most cases, this checks that the given special member function `s` has a user-provided
   * body (other than `= default;` or `= delete;`).
   *
   * If the class has copy operations that act in place of the move operations, that means the
   * corresponding move operation was not declared, so we say this predicate does not hold for the
   * given move operation `s`.
   */
  predicate isCustomized(TSpecialMember s) {
    s instanceof TMoveConstructor and
    isMemberCustomized(moveCtor) and
    declaresMoveConstructor()
    or
    s instanceof TMoveAssignmentOperator and
    isMemberCustomized(moveAssign) and
    declaresMoveAssignmentOperator()
    or
    s instanceof TCopyConstructor and isMemberCustomized(copyCtor)
    or
    s instanceof TCopyAssignmentOperator and isMemberCustomized(copyAssign)
    or
    s instanceof TDestructor and isMemberCustomized(dtor)
  }

  /**
   * Holds if this class declares a move constructor.
   *
   * This will be true if move constructor resolution found a non-implicit constructor that is not
   * the copy constructor masquerading as a move constructor.
   */
  predicate declaresMoveConstructor() { not moveCtor = copyCtor and isUserDeclared(moveCtor) }

  /**
   * Holds if this class declares a move assignment operator.
   *
   * This will be true if move assignment resolution found a non-implicit operator that is not
   * the copy assignment operator masquerading as a move assignment operator.
   */
  predicate declaresMoveAssignmentOperator() {
    not moveAssign = copyAssign and isUserDeclared(moveAssign)
  }
}
