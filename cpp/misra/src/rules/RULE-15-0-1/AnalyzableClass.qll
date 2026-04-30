import cpp

private predicate isUsable(MemberFunction f) {
  not f.isDeleted() and
  f.isPublic()
}

private predicate isMemberCustomized(MemberFunction f) {
  exists(f.getDefinition()) and
  not f.isDefaulted() and
  not f.isDeleted() and
  not f.isCompilerGenerated()
}

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
  isUserDeclared(c.getAConstructor().(CopyAssignmentOperator))
  or
  isUserDeclared(c.getDestructor())
}

Constructor getMoveConstructor(Class c) {
  if
    not exists(MoveConstructor mc | mc = c.getAConstructor() and isUserDeclared(mc)) and
    implicitMoveIsSuppressed(c)
  then result = c.getAConstructor().(CopyConstructor)
  else result = c.getAConstructor().(MoveConstructor)
}

Operator getMoveAssign(Class c) {
  if
    not exists(MoveAssignmentOperator mc | mc = c.getAMemberFunction() and isUserDeclared(mc)) and
    implicitMoveIsSuppressed(c)
  then result = c.getAMemberFunction().(CopyAssignmentOperator)
  else result = c.getAMemberFunction().(MoveAssignmentOperator)
}

newtype TSpecialMember =
  TMoveConstructor() or
  TMoveAssignmentOperator() or
  TCopyConstructor() or
  TCopyAssignmentOperator() or
  TDestructor()

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

  predicate exposes(TSpecialMember m) {
    m instanceof TMoveConstructor and moveConstructible()
    or
    m instanceof TMoveAssignmentOperator and moveAssignable()
    or
    m instanceof TCopyConstructor and copyConstructible()
    or
    m instanceof TCopyAssignmentOperator and copyAssignable()
    or
    m instanceof TDestructor and destructible()
  }

  predicate moveConstructible() { isUsable(moveCtor) }

  predicate copyConstructible() { isUsable(copyCtor) }

  predicate moveAssignable() { isUsable(moveAssign) }

  predicate copyAssignable() { isUsable(copyAssign) }

  predicate destructible() { isUsable(dtor) }

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

  predicate declaresMoveConstructor() { not moveCtor = copyCtor }

  predicate declaresMoveAssignmentOperator() { not moveAssign = copyAssign }
}
