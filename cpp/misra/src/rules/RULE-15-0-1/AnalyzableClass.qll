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

newtype TSpecialMember =
  TMoveConstructor() or
  TMoveAssignmentOperator() or
  TCopyConstructor() or
  TCopyAssignmentOperator() or
  TDestructor()

class AnalyzableClass extends Class {
  MoveConstructor moveCtor;
  MoveAssignmentOperator moveAssign;
  CopyConstructor copyCtor;
  CopyAssignmentOperator copyAssign;
  Destructor dtor;

  AnalyzableClass() {
    moveCtor = this.getAConstructor() and
    copyCtor = this.getAConstructor() and
    moveAssign = this.getAMemberFunction() and
    copyAssign = this.getAMemberFunction() and
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
    s instanceof TMoveConstructor and isMemberCustomized(moveCtor)
    or
    s instanceof TMoveAssignmentOperator and isMemberCustomized(moveAssign)
    or
    s instanceof TCopyConstructor and isMemberCustomized(copyCtor)
    or
    s instanceof TCopyAssignmentOperator and isMemberCustomized(copyAssign)
    or
    s instanceof TDestructor and isMemberCustomized(dtor)
  }
}
