/**
 * A module for representing pointers
 */

import cpp
import codingstandards.cpp.Type

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
