import cpp

predicate mustBeImplicitlyDefined(Function mf) {
  // If it exists and its defaulted, it must be implicitly defined
  mf.isCompilerGenerated() or mf.isDefaulted()
}

predicate mustNotBeImplicitlyDefined(Function mf) {
  // Sanity check: exclude member functions that are definitely user defined!
  not mustBeImplicitlyDefined(mf) and
  (
    // If the user wrote a body, it's not implicitly defined
    not mf.isCompilerGenerated()
    or
    // Deleted functions have no definition at all
    mf.isDeleted()
  )
}

predicate mustBeUserDeclared(Function mf) {
  exists(FunctionDeclarationEntry fde | fde.getFunction() = mf and not fde.isImplicit())
}

predicate mustNotBeUserDeclared(Function mf) {
  // use forex: at least one declaration must exist, and all declarations must be implicit
  forex(FunctionDeclarationEntry fde | fde.getFunction() = mf | fde.isImplicit())
}

private signature class SpecialMember extends Function;

private signature predicate constraint(Function mf);

/**
 * Implicitly defined copy constructors are deprecated if the class has a user-declared copy
 * assignment operator or a user-declared destructor. The same is true for the reverse case
 * (implicit copy assignment operators check for copy constructors).
 *
 * Unfortunately, trivial copy constructors, assignment operators, and destructors are often missing
 * from the database, so we can only approximate.
 *
 * To manage all of the negatives, double negatives, musts, mays, and may nots, the problem is
 * broken down into sets as defined below.
 *
 * Firstly:
 * - CC=copy constructor, CA=copy assignment operator, D=destructor
 * - IDEF = implicitly defined, UDEC = user declared
 *
 * and:
 * - C_has{X} = set of all classes T for which "class T has a {X}"
 * - C_mustHave{X} = set of all classes T for which "class T must have a {X}"
 * - C_cannotHave{X} = set of all classes T for which "class T cannot have a {X}"
 * - C_mayHave{X} = not C_cannotHave{X}
 *
 * then we can find all cases we know to be deprecated via:
 * - Step 1: find C_mustHave{IDEF CC}, C_mustHave{IDEF CA}
 * - Step 2: find C_mustHave{UDEC CC}, C_mustHave{UDEC CA}, C_mustHave{UDEC D}
 * - Step 3: All C' are deprecated where C' in C_mustHave{IDEF CC} and (C' in C_mustHave{UDEC CA} or C' in C_mustHave{UDEC D})
 * - Step 4: All C' are deprecated where C' in C_mustHave{IDEF CA} and (C' in C_mustHave{UDEC CC} or C' in C_mustHave{UDEC D})
 *
 * And all cases we may consider deprecated via:
 * - Step 5: find C_cannotHave{IDEF CC}, C_cannotHave{IDEF CA}
 * - Step 6: find C_mayHave{IDEF CC}, C_mayHave{IDEF CA} (by negating the cannot sets)
 * - Step 7: find C_cannotHave{UDEC CC}, C_cannotHave{UDEC CA}, C_cannotHave{UDEC D}
 * - Step 8: find C_mayHave{UDEC CC}, C_mayHave{UDEC CA}, C_mayHave{UDEC D} (by negating the cannot sets)
 * - Step 9: All C' may be deprecated where C' in C_mayHave{IDEF CC} and (C' in C_mayHave{UDEC CA} or C' in C_mayHave{UDEC D})
 * - Step 10: All C' may be deprecated where C' in C_mayHave{IDEF CA} and (C' in C_mayHave{UDEC CC} or C' in C_mayHave{UDEC D})
 *
 * This is performed through the various instantiations of this module.
 */
private module ClassesWhere<constraint/1 pred, SpecialMember Member> {
  final class FinalClass = Class;

  class Matching extends FinalClass {
    Matching() { exists(Member member | member.getDeclaringType() = this and pred(member)) }
  }

  class NotMatching extends FinalClass {
    NotMatching() { not this instanceof Matching }
  }
}

/* Step 1: find C_mustHave{IDEF CC}, C_mustHave{IDEF CA} */
private class CMustHaveIdefCC = ClassesWhere<mustBeImplicitlyDefined/1, CopyConstructor>::Matching;

private class CMustHaveIdefCA =
  ClassesWhere<mustBeImplicitlyDefined/1, CopyAssignmentOperator>::Matching;

/* Step 2: find C_mustHave{UDEC CC}, C_mustHave{UDEC CA}, C_mustHave{UDEC D} */
private class CMustHaveUdecCC = ClassesWhere<mustBeUserDeclared/1, CopyConstructor>::Matching;

private class CMustHaveUdecCA =
  ClassesWhere<mustBeUserDeclared/1, CopyAssignmentOperator>::Matching;

private class CMustHaveUdecD = ClassesWhere<mustBeUserDeclared/1, Destructor>::Matching;

/* - Step 3: All C' are deprecated where C' in C_mustHave{IDEF CC} and (C' in C_mustHave{UDEC CA} or C' in C_mustHave{UDEC D}) */
class MustHaveDeprecatedCopyConstructor extends CMustHaveIdefCC {
  MustHaveDeprecatedCopyConstructor() {
    this instanceof CMustHaveUdecCA or this instanceof CMustHaveUdecD
  }
}

/* - Step 4: All C' are deprecated where C' in C_mustHave{IDEF CA} and (C' in C_mustHave{UDEC CC} or C' in C_mustHave{UDEC D}) */
class MustHaveDeprecatedCopyAssignmentOperator extends CMustHaveIdefCA {
  MustHaveDeprecatedCopyAssignmentOperator() {
    this instanceof CMustHaveUdecCC or this instanceof CMustHaveUdecD
  }
}

/**
 * Step 5: find C_cannotHave{IDEF CC}, C_cannotHave{IDEF CA}
 * Step 6: find C_mayHave{IDEF CC}, C_mayHave{IDEF CA} (by negating the cannot sets)
 *
 * In our case, `ClassesWhere<...>` performs steps 5 and 6 together via `NotMatching`.
 */
private class CMayHaveIdefCC =
  ClassesWhere<mustNotBeImplicitlyDefined/1, CopyConstructor>::NotMatching;

private class CMayHaveIdefCA =
  ClassesWhere<mustNotBeImplicitlyDefined/1, CopyAssignmentOperator>::NotMatching;

/**
 * Step 7: find C_cannotHave{UDEC CC}, C_cannotHave{UDEC CA}, C_cannotHave{UDEC D}
 * Step 8: find C_mayHave{UDEC CC}, C_mayHave{UDEC CA}, C_mayHave{UDEC D} (by negating the cannot sets)
 *
 * In our case, `ClassesWhere<...>` performs steps 7 and 8 together via `NotMatching`.
 */
private class CMayHaveUdecCC = ClassesWhere<mustNotBeUserDeclared/1, CopyConstructor>::NotMatching;

private class CMayHaveUdecCA =
  ClassesWhere<mustNotBeUserDeclared/1, CopyAssignmentOperator>::NotMatching;

private class CMayHaveUdecD = ClassesWhere<mustNotBeUserDeclared/1, Destructor>::NotMatching;

/* - Step 9: All C' may be deprecated where C' in C_mayHave{IDEF CC} and (C' in C_mayHave{UDEC CA} or C' in C_mayHave{UDEC D}) */
class MayHaveDeprecatedCopyConstructor extends CMayHaveIdefCC {
  MayHaveDeprecatedCopyConstructor() {
    this instanceof CMayHaveUdecCA or this instanceof CMayHaveUdecD
  }
}

/* - Step 10: All C' may be deprecated where C' in C_mayHave{IDEF CA} and (C' in C_mayHave{UDEC CC} or C' in C_mayHave{UDEC D}) */
class MayHaveDeprecatedCopyAssignmentOperator extends CMayHaveIdefCA {
  MayHaveDeprecatedCopyAssignmentOperator() {
    this instanceof CMayHaveUdecCC or this instanceof CMayHaveUdecD
  }
}
