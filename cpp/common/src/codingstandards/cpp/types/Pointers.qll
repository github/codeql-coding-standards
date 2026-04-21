/**
 * A module for representing pointers
 */

import cpp
import codingstandards.cpp.Type

/**
 * A type that is a pointer or array type after stripping top-level specifiers.
 */
class PointerOrArrayType extends DerivedType {
  PointerOrArrayType() {
    this.stripTopLevelSpecifiers() instanceof PointerType or
    this.stripTopLevelSpecifiers() instanceof ArrayType
  }
}

/**
 * A type that is a pointer or array type.
 */
class UnspecifiedPointerOrArrayType extends DerivedType {
  UnspecifiedPointerOrArrayType() {
    this instanceof PointerType or
    this instanceof ArrayType
  }
}

/**
 * An expression which performs pointer arithmetic
 */
abstract class PointerArithmeticExpr extends Expr {
  abstract Expr getPointer();

  abstract Expr getOperand();
}

/**
 * A pointer arithmetic binary operation expression.
 */
class SimplePointerArithmeticExpr extends PointerArithmeticExpr, PointerArithmeticOperation {
  override Expr getPointer() { result = this.getLeftOperand() }

  override Expr getOperand() { result = this.getRightOperand() }
}

/**
 * A pointer arithmetic assignment expression.
 */
class AssignPointerArithmeticExpr extends PointerArithmeticExpr, AssignOperation {
  AssignPointerArithmeticExpr() {
    this instanceof AssignPointerAddExpr or
    this instanceof AssignPointerSubExpr
  }

  override Expr getPointer() { result = this.getLValue() }

  override Expr getOperand() { result = this.getRValue() }
}

/**
 * A pointer arithmetic array access expression.
 */
class ArrayPointerArithmeticExpr extends PointerArithmeticExpr, ArrayExpr {
  override Expr getPointer() { result = this.getArrayBase() }

  override Expr getOperand() { result = this.getArrayOffset() }
}

/**
 * A null pointer constant, which is either in the form `NULL` or `(void *)0`.
 */
predicate isNullPointerConstant(Expr e) {
  e.findRootCause() instanceof NullMacro
  or
  // 8.11 Pointer type conversions states:
  // A null pointer constant, i.e. the value 0, optionally cast to void *.
  e instanceof Zero
  or
  isNullPointerConstant(e.(Conversion).getExpr())
}

predicate isCastNullPointerConstant(Cast c) {
  isNullPointerConstant(c.getExpr()) and
  c.getUnderlyingType() instanceof PointerType
}

/**
 * A type representing a pointer to object
 */
class PointerToObjectType extends PointerType {
  PointerToObjectType() {
    not (
      this.getUnspecifiedType() instanceof FunctionPointerType or
      this.getUnspecifiedType() instanceof VoidPointerType or
      this.getBaseType().getUnspecifiedType() instanceof IncompleteType
    )
  }
}

/**
 * Gets the base type of a pointer or array type.  In the case of an array of
 * arrays, the inner base type is returned.
 *
 * Copied from IncorrectPointerScalingCommon.qll.
 */
Type baseType(Type t) {
  (
    exists(PointerType dt |
      dt = t.getUnspecifiedType() and
      result = dt.getBaseType().getUnspecifiedType()
    )
    or
    exists(ArrayType at |
      at = t.getUnspecifiedType() and
      not at.getBaseType().getUnspecifiedType() instanceof ArrayType and
      result = at.getBaseType().getUnspecifiedType()
    )
    or
    exists(ArrayType at, ArrayType at2 |
      at = t.getUnspecifiedType() and
      at2 = at.getBaseType().getUnspecifiedType() and
      result = baseType(at2)
    )
  ) and
  // Make sure that the type has a size and that it isn't ambiguous.
  strictcount(result.getSize()) = 1
}

/**
 * A `Type` that may be a pointer, array, or reference, to a const or a non-const type.
 *
 * For example, `const int*`, `int* const`, `const int* const`, `int*`, `int&`, `const int&` are all
 * `PointerLikeType`s, while `int`, `int&&`, and `const int` are not.
 *
 * To check if a `PointerLikeType` points/refers to a const-qualified type, use the `pointsToConst()`
 * predicate.
 */
class PointerLikeType extends Type {
  Type innerType;
  Type outerType;

  PointerLikeType() {
    innerType = this.(UnspecifiedPointerOrArrayType).getBaseType() and
    outerType = this
    or
    innerType = this.(LValueReferenceType).getBaseType() and
    outerType = this
    or
    exists(PointerLikeType stripped |
      stripped = this.stripTopLevelSpecifiers() and not stripped = this
    |
      innerType = stripped.getInnerType() and
      outerType = stripped.getOuterType()
    )
  }

  /**
   * Gets the pointed to or referred to type, for instance `int` for `int*` or `const int&`.
   */
  Type getInnerType() { result = innerType }

  /**
   * Gets the resolved pointer, array, or reference type itself, for instance `int*` in `int* const`.
   *
   * Removes cv-qualification and resolves typedefs and decltypes and specifiers via
   * `stripTopLevelSpecifiers()`.
   */
  Type getOuterType() { result = outerType }

  /**
   * Holds when this type points to const -- for example, `const int*` and `const int&` point to
   * const, while `int*`, `int *const` and `int&` do not.
   */
  predicate pointsToConst() { innerType.isConst() }

  /**
   * Holds when this type points to non-const -- for example, `int*` and `int&` and `int *const`
   * point to non-const, while `const int*`, `const int&` do not.
   */
  predicate pointsToNonConst() { not innerType.isConst() }
}

/**
 * Gets usages of this parameter that maintain pointer-like semantics -- typically this means
 * either a normal access, or switching between pointers and reference semantics.
 *
 * Examples of accesses with pointer-like semantics include:
 * - `ref` in `int &x = ref`, or `&ref` in `int *x = &ref`;
 * - `ptr` in `int *x = ptr`, or `*ptr` in `int &x = *ptr`;
 *
 * In the above examples, we can still access the value pointed to by `ref` or `ptr` through the
 * expression.
 *
 * Examples of non-pointer-like semantics include:
 * - `ref` in `int x = ref` and `*ptr` in `int x = *ptr`;
 *
 * In the above examples, the value pointed to by `ref` or `ptr` is copied and the expression
 * refers to a new/different object.
 */
Expr getAPointerLikeAccessOf(Expr expr) {
  exists(PointerLikeType pointerLikeType | pointerLikeType = expr.getType() |
    result = expr
    or
    // For reference parameters, also consider accesses to the parameter itself as accesses to the referent
    pointerLikeType.getOuterType() instanceof ReferenceType and
    result.(AddressOfExpr).getOperand() = expr
    or
    // A pointer is dereferenced, but the result is not copied
    pointerLikeType.getOuterType() instanceof PointerType and
    result.(PointerDereferenceExpr).getOperand() = expr and
    not any(ReferenceDereferenceExpr rde).getExpr() = result.getConversion+()
  )
}
