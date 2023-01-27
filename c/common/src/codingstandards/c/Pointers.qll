/**
 * A module for representing pointers
 */

import cpp
import codingstandards.cpp.Type

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
  e.findRootCause() instanceof NULLMacro
  or
  exists(CStyleCast c |
    not c.isImplicit() and
    c.getExpr() = e and
    e instanceof Zero and
    c.getType() instanceof VoidPointerType
  )
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
      this.getUnderlyingType() instanceof FunctionPointerType or
      this.getUnderlyingType() instanceof VoidPointerType or
      this.getBaseType().getUnderlyingType() instanceof IncompleteType
    )
  }
}
