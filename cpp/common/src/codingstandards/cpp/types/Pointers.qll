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
