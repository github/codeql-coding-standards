/**
 * Provides a library for identifying scalar, literal and trivial types, as specified by the C++14
 * standard.
 */

import cpp

predicate isClassOrArrayOfClass(Type t) {
  t instanceof Class
  or
  t.(ArrayType).getBaseType() instanceof Class
}

abstract class TrivialConstructor extends Constructor { }

/** A function is user provided if it is not compiler generated, not defaulted and not deleted (see [dcl.fct.def.default]/5). */
predicate isUserProvided(Function f) {
  not f.isCompilerGenerated() and
  not f.isDefaulted() and
  not f.isDeleted()
}

/** Holds if `c` is a candidate for a trivial move or copy constructor. */
private predicate isCandidateForTrivialCopyMoveConstructor(Class c) {
  not c.getAMemberFunction().isVirtual() and
  not c = any(VirtualBaseClass vbc).getAVirtuallyDerivedClass().getADerivedClass*() and
  // No fields (i.e. non static member variables) which are volatile
  not c.getAField().isVolatile()
}

/** Holds if `c` has a trivial move constructor (see [class.copy]/12). */
predicate hasTrivialMoveConstructor(Class c) {
  // Has an explicitly represented trivial move constructor
  exists(MoveConstructor mc | mc = c.getAConstructor() | mc instanceof TrivialCopyOrMoveConstructor)
  or
  // Not all trivial move constructors are represented in the database, so we have to validate against the requirements
  // No existing move constructors
  not c.getAConstructor() instanceof MoveConstructor and
  isCandidateForTrivialCopyMoveConstructor(c) and
  // All member variables of Class or Class[] type have trivial move constructors
  forall(Field f |
    f = c.getAField() and
    isClassOrArrayOfClass(f.getType())
  |
    hasTrivialMoveConstructor(f.getType())
  ) and
  // All base classes have trivial move constructors
  forall(Class baseClass | baseClass = c.getABaseClass() | hasTrivialMoveConstructor(baseClass)) and
  // The class has to be defined, otherwise we may not see the information required to deduce
  // whether it does or does not have a trivial move constructor
  c.hasDefinition()
}

/** A trivial copy or move constructor (see [class.copy]/12). */
class TrivialCopyOrMoveConstructor extends Constructor, TrivialConstructor {
  TrivialCopyOrMoveConstructor() {
    // Copy or move constructor
    (this instanceof CopyConstructor or this instanceof MoveConstructor) and
    not isUserProvided(this) and
    isCandidateForTrivialCopyMoveConstructor(getDeclaringType()) and
    // The constructor selected to copy/move each direct base class subobjects is trivial
    // NOTE: The way EDG works, we may only have a declaration for implicitly declared constructors, if
    //       the implementation is deemed to be simple or a no-op.
    forall(ConstructorBaseInit baseInit | baseInit = getAnInitializer() |
      baseInit.getTarget() instanceof TrivialConstructor
    ) and
    // Non-static member variables which are classes or arrays of classes are initialized by trivial constructors
    forall(ConstructorFieldInit fieldInit |
      fieldInit = getAnInitializer() and
      isClassOrArrayOfClass(fieldInit.getType())
    |
      fieldInit.getExpr().(ConstructorCall).getTarget() instanceof TrivialConstructor
    )
  }
}

private class CopyOrMoveAssignmentOperatorCall extends Call {
  CopyOrMoveAssignmentOperatorCall() {
    getTarget() instanceof CopyAssignmentOperator
    or
    getTarget() instanceof MoveAssignmentOperator
  }
}

class TrivialCopyOrMoveAssignmentOperator extends Operator {
  TrivialCopyOrMoveAssignmentOperator() {
    // Copy or move constructor
    (this instanceof CopyAssignmentOperator or this instanceof MoveAssignmentOperator) and
    not isUserProvided(this) and
    // No virtual functions or virtual base classes
    not getDeclaringType().getAMemberFunction().isVirtual() and
    not getDeclaringType().getADerivation().isVirtual() and
    // No fields (i.e. non static member variables) which are volatile
    not getDeclaringType().getAField().isVolatile() and
    // No fields (i.e. non static member variables) with `Class` or `Class[]` types which are assigned using non-trivial assignment
    forall(CopyOrMoveAssignmentOperatorCall assignmentOpCall |
      // Find a copy/move assignment op call in the body of the generated operator
      assignmentOpCall = getBlock().getAChild().(ExprStmt).getExpr() and
      // Find the field it is initializing, and the type initialize
      exists(Field field |
        // Find the field being assigned from in the op call
        field = assignmentOpCall.getArgument(0).(FieldAccess).getTarget() and
        // Confirm that it is a field on this type
        field = getDeclaringType().getAField() and
        isClassOrArrayOfClass(field.getType()) // TODO how are arrays init-ed in the generated model?
      )
    |
      assignmentOpCall.getTarget() instanceof TrivialCopyOrMoveAssignmentOperator
    )
  }
}

private predicate isCandidateForTrivialDestructor(Class c) {
  // All direct base classes have trivial destructors
  forall(Class baseClass | baseClass = c.getABaseClass() | hasTrivialDestructor(baseClass)) and
  // All non-static data members that are of Class or array of Class type should have a trivial destructor
  // All fields with Class or Class[] type have trivial destructors
  forall(Type fieldType, Class classType |
    fieldType = c.getAField().getType() and
    (
      classType = fieldType
      or
      classType = fieldType.(ArrayType).getBaseType()
    )
  |
    hasTrivialDestructor(classType)
  )
}

/**
 * A "trivial destructor" (see [class.dtor]/5).
 *
 * Note: not all trivial destructors are stored in the database. Use `hasTrivialDestructor` to
 * determine whether a `Class` has a trivial destructor, instead of checking whether the
 * destructor is an `instanceof TrivialDestructor`.
 */
class TrivialDestructor extends Destructor {
  TrivialDestructor() {
    // Not user-provided
    (isDefaulted() or isCompilerGenerated()) and
    // Not virtual
    not isVirtual() and
    isCandidateForTrivialDestructor(getDeclaringType()) and
    // Not deleted
    not isDeleted() // NOTE: this doesn't appear to be supported by the extractor
  }
}

/**
 * Holds if `c` has a trivial destructor (see [class.dtor]/6.5).
 *
 * Note: this is not the same as asking if the `getDestructor()` for the class is trivial, because
 * the trivial destructor is sometimes omitted from the database.
 */
predicate hasTrivialDestructor(Class c) {
  // An "explicit" trivial destructor
  c.getDestructor() instanceof TrivialDestructor
  or
  // In some cases the destructor is not explicitly added to the database, but we can infer that it
  // should be there
  not exists(c.getDestructor()) and
  isCandidateForTrivialDestructor(c)
  // NOTE: In some cases the C++ Standard specifies that the compiler-generated destructor should be
  // defined "deleted". In this case, the destructor is not in the database, but that does not mean
  // a trivial destructor has been created. These cases are often niche, and we prefer to over
  // approximate, so these are not handled here.
}

/** A "trivially copyable class" (see [class]/6). */
class TriviallyCopyableClass extends Class {
  TriviallyCopyableClass() {
    // No non-trivial copy constructors (see [class]/6.1)
    forall(CopyConstructor c | c = getAConstructor() | c instanceof TrivialCopyOrMoveConstructor) and
    // No non-trivial move constructors (see [class]/6.2)
    forall(MoveConstructor c | c = getAConstructor() | c instanceof TrivialCopyOrMoveConstructor) and
    // No non-trivial copy assignment operators (see [class]/6.3)
    forall(CopyAssignmentOperator c | c = getAMemberFunction() |
      c instanceof TrivialCopyOrMoveAssignmentOperator
    ) and
    // No non-trivial move assignment operators (see [class]/6.4)
    forall(MoveAssignmentOperator c | c = getAMemberFunction() |
      c instanceof TrivialCopyOrMoveAssignmentOperator
    ) and
    hasTrivialDestructor(this)
  }
}

private predicate isCandidateForTrivialDefaultConstructor(Class c) {
  // No virtual functions
  not c.getAMemberFunction().isVirtual() and
  // No NSDMI
  not exists(c.getAField().getInitializer()) and
  // All base classes have trivial default constructors
  forall(Class baseClass | baseClass = c.getABaseClass() | hasTrivialDefaultConstructor(baseClass)) and
  // All non-static data members that are of class or array of class should have a trivial default constructor
  forall(Type fieldType, Class classType |
    fieldType = c.getAField().getType() and
    (
      classType = fieldType
      or
      classType = fieldType.(ArrayType).getBaseType()
    )
  |
    hasTrivialDefaultConstructor(classType)
  )
}

/**
 * A "trivial default constructor" (see [class.ctor]/4.8-[class.ctor]/4.11).
 *
 * Note: not all trivial default constructors are stored in the database. Use `hasTrivialDefaultConstructor` to
 * determine whether a `Class` has a trivial default constructor, instead of checking whether the constructor is an
 * `instanceof TrivialDefaultConstructor`.
 */
class TrivialDefaultConstructor extends TrivialConstructor {
  TrivialDefaultConstructor() {
    // Not user-provided
    (isDefaulted() or isCompilerGenerated()) and
    // Is a default constructor
    isDefault() and
    // Not deleted
    not isDeleted() and
    // Class satisfies the requirements for having a default trivial constructor
    isCandidateForTrivialDefaultConstructor(getDeclaringType())
  }
}

/**
 * Holds if `c` has a trivial default constructor (see [class.ctor]/4.8-[class.ctor]/4.11).
 *
 * Note: this is not the same as asking if the `getAConstructor()` for the class is an
 * `instanceof TrivialDefaultConstructor`, because the trivial constructor is sometimes omitted
 * from the database.
 */
predicate hasTrivialDefaultConstructor(Class c) {
  c.getAConstructor() instanceof TrivialDefaultConstructor
  or
  not exists(c.getAConstructor()) and
  isCandidateForTrivialDefaultConstructor(c)
  // NOTE: In some cases the C++ Standard specifies that the compiler-generated constructor should
  // be defined "deleted". In this case, the constructor is not in the database, but that does not
  // mean a trivial constructor has been created. These cases are often niche, and we prefer to over
  // approximate, so these are not handled here.
}

/** A "trivial class" (see [class]/6). */
class TrivialClass extends TriviallyCopyableClass {
  TrivialClass() {
    // A default constructor exists
    hasTrivialDefaultConstructor(this) and
    // No non-trivial default constructors
    forall(Constructor c | c = getAConstructor() and c.isDefault() |
      c instanceof TrivialDefaultConstructor
    )
  }
}

/** Holds if `t` is a scalar type (see [basic.types]/9). */
predicate isScalarType(Type t) {
  t instanceof ArithmeticType
  or
  t instanceof Enum
  or
  t instanceof PointerType
  or
  t instanceof PointerToMemberType
  or
  t instanceof NullPointerType
  or
  isScalarType(t.getUnspecifiedType())
}

/** Holds if `t` is a scalar type (see [basic.types]/9). */
predicate isTrivialType(Type t) {
  isScalarType(t)
  or
  t instanceof TrivialClass
  or
  isTrivialType(t.(ArrayType).getBaseType())
  or
  isTrivialType(t.getUnspecifiedType())
}

/** Holds if `t` is a trivially copyable type. */
predicate isTriviallyCopyableType(Type t) {
  isScalarType(t)
  or
  t instanceof TriviallyCopyableClass
  or
  isTriviallyCopyableType(t.(ArrayType).getBaseType())
  or
  isTriviallyCopyableType(t.getUnspecifiedType())
}

/** A POD type as defined by [basic.types]/9. */
class PODType extends Type {
  PODType() {
    this.(Class).isPod()
    or
    isScalarType(this)
    or
    this.(ArrayType).getBaseType() instanceof PODType
    or
    this.getUnspecifiedType() instanceof PODType
  }
}

/**
 * Holds if `c` is an aggregate class according to `[dcl.init.aggr]/1`.
 */
predicate isAggregateClass(Class c) {
  not c instanceof TemplateClass and
  // No user-provided constructors
  not exists(Constructor constructor |
    constructor = c.getAConstructor() and
    not constructor.isCompilerGenerated() and
    not constructor.isDefaulted() and
    not constructor.isDeleted()
  ) and
  // No private or protected non-static data members
  not exists(Field f | f = c.getAField() |
    f.isPrivate() or
    f.isProtected()
  ) and
  // no base classes
  not exists(c.getABaseClass()) and
  // No virtual member functions
  not exists(VirtualFunction f | f.getDeclaringType() = c)
}

/**
 * Holds if `t` is an aggregate type according to `[dcl.init.aggr]/1`.
 */
predicate isAggregateType(Type t) {
  exists(Type ut | ut = t.getUnderlyingType() |
    ut instanceof ArrayType or
    isAggregateClass(ut)
  )
}

/**
 * Holds if `t` is a literal type according to `[basic.types]/10`.
 */
predicate isLiteralType(Type t) {
  t instanceof VoidType
  or
  isScalarType(t)
  or
  t instanceof ReferenceType
  or
  isLiteralType(t.(ArrayType).getBaseType())
  or
  isLiteralType(t.getUnspecifiedType())
  or
  exists(Class c | c = t |
    hasTrivialDestructor(c) and
    (
      isAggregateClass(c)
      or
      exists(Constructor constructor | constructor = c.getAConstructor() |
        constructor.isConstexpr() and
        not constructor instanceof MoveConstructor and
        not constructor instanceof CopyConstructor
      )
      or
      hasTrivialDefaultConstructor(c)
    ) and
    if c instanceof Union
    then
      exists(Type fieldType | fieldType = c.getAField().getType() |
        isLiteralType(fieldType) and not fieldType.isVolatile()
      )
    else
      forall(Type fieldType | fieldType = c.getAField().getType() |
        isLiteralType(fieldType) and not fieldType.isVolatile()
      )
  )
}
