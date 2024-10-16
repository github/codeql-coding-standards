import cpp
import codingstandards.cpp.Clvalues

/**
 * A struct or union type that contains an array type.
 */
class StructOrUnionTypeWithArrayField extends Struct {
  StructOrUnionTypeWithArrayField() {
    this.getAField().getUnspecifiedType() instanceof ArrayType
    or
    // nested struct or union containing an array type
    this.getAField().getUnspecifiedType().(Struct) instanceof StructOrUnionTypeWithArrayField
  }
}

/**
 * A non-lvalue expression with struct or or union type that has a field member
 * of array type, has a temporary lifetime.
 *
 * The array members are also part of that object, and thus also have temporary
 * lifetime.
 */
class TemporaryLifetimeExpr extends Expr {
  TemporaryLifetimeExpr() {
    getUnconverted().getUnspecifiedType() instanceof StructOrUnionTypeWithArrayField and
    not isCLValue(this)
    or
    this.(ArrayExpr).getArrayBase() instanceof TemporaryLifetimeArrayAccess
  }
}

/**
 * A field access on a temporary object that returns an array member.
 */
class TemporaryLifetimeArrayAccess extends FieldAccess {
  // The temporary lifetime object which owns the array that is returned.
  TemporaryLifetimeExpr temporary;

  TemporaryLifetimeArrayAccess() {
    getQualifier().getUnconverted() = temporary and
    getUnspecifiedType() instanceof ArrayType
  }

  /**
   * Get the temporary lifetime object which own the array that is returned.
   */
  Expr getTemporary() { result = temporary }
}
