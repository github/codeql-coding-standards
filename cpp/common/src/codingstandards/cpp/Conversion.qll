/**
 * A module for additional predicates and classes related to conversions.
 */

import cpp
import codingstandards.cpp.Operator
import codingstandards.cpp.Cpp14Literal

/**
 * A `static_cast` or C-style cast.
 */
class StaticOrCStyleCast extends Cast {
  StaticOrCStyleCast() {
    this instanceof CStyleCast
    or
    this instanceof StaticCast
  }
}

/** Gets a string representation of the expression being converted that can be used as part of an alert message. */
string getConversionExprDescription(Conversion c) {
  if c.getExpr() instanceof Access
  then result = c.getExpr().(Access).getTarget().getName()
  else
    if c.getExpr() instanceof Literal
    then result = c.getExpr().(Literal).getValueText()
    else result = "expression"
}

/**
 * A conversion from a float to an integral or vica versa.
 *
 * Per [conv.fpint] in N3787:
 * The conversion from a float to an integral discards the fractional part
 * and the behavior is undefined if the truncated value cannot be represented in the destination type.
 *
 * The conversion from an integral to a float is exact if possible.
 * If the result cannot be represented, but is in the range of representable values the next lower or higher representable
 * value is chosen. The behavior is undefined if the value is outside the range of values that can be represented.
 *
 * Since the value representation of floating points is implementation defined we cannot decided if an integral is
 * is exactly representable by a float and make no effort to try and detect it.
 */
class FloatingIntegralConversion extends ArithmeticConversion {
  FloatingIntegralConversion() {
    this instanceof FloatingPointToIntegralConversion
    or
    this instanceof IntegralToFloatingPointConversion
  }

  /** Gets a string representation of the conversion. */
  string getDirection() {
    this instanceof FloatingPointToIntegralConversion and result = "float to integral"
    or
    this instanceof IntegralToFloatingPointConversion and result = "integral to float"
  }

  /** Gets a description of the expression being converted. */
  string getDescription() { result = getConversionExprDescription(this) }
}

/** A value preserving conversion that is implicitly applied to balance types. */
class IntegralPromotion extends IntegralConversion {
  IntegralPromotion() {
    isImplicit() and
    exists(IntegralOrEnumType type, IntegralType promotedType, boolean isBitField |
      type = getExpr().getUnderlyingType() and
      promotedType = getUnderlyingType() and
      if getExpr().(FieldAccess).getTarget() instanceof BitField
      then isBitField = true
      else isBitField = false
    |
      (
        type.(CharType).isSigned()
        or
        type.(ShortType).isSigned()
        or
        type instanceof BoolType
      ) and
      promotedType.(IntType).isSigned()
      or
      (
        type.(CharType).isUnsigned()
        or
        type instanceof Char8Type
        or
        type.(ShortType).isUnsigned()
      ) and
      promotedType instanceof IntType
      or
      (
        type instanceof Wchar_t
        or
        type instanceof Char16Type
        or
        type instanceof Char32Type
        or
        type instanceof Enum and not type instanceof ScopedEnum
      ) and
      (
        promotedType instanceof IntType
        or
        (
          promotedType instanceof LongType or
          promotedType instanceof LongLongType
        ) and
        // A bit field type can be converted to `int` or `unsigned int`.
        // If the value range cannot be represented in an int,no promotion is applied.
        isBitField = false
      )
    )
  }
}

/** A module containing classess and predicates to reason about Misra specific conversions. */
module MisraConversion {
  /** A conversion of a Misra cvalue. */
  class CValueConversion extends ArithmeticConversion {
    MisraExpr::CValue cvalue;

    CValueConversion() { cvalue = this.getExpr() }

    /** Gets the cvalue being converted. */
    MisraExpr::CValue getCValue() { result = cvalue }
  }

  /** An explicit conversion of a Misra cvalue. */
  class ExplicitCValueConversion extends CValueConversion {
    ExplicitCValueConversion() { not this.isImplicit() }
  }

  /** An implict integral conversion that is not an integral promotion. */
  class ImplicitIntegralConversion extends IntegralConversion {
    ImplicitIntegralConversion() {
      isImplicit() and
      // Exclude integral promotions, because the underlying type is a model of the C++ language
      // without integral promotions
      not this instanceof IntegralPromotion
    }
  }

  /** A canonical `IntegralType`, such that there is at most one type for each pair (size,signedness). */
  private class CanonicalIntegralType extends IntegralType {
    CanonicalIntegralType() {
      (isExplicitlySigned() or isExplicitlyUnsigned()) and
      // If there are multiple canonical types, then choose the one with the smallest name
      this.getName() =
        min(IntegralType t |
          (
            t.isExplicitlySigned() and this.isExplicitlySigned()
            or
            t.isExplicitlyUnsigned() and this.isExplicitlyUnsigned()
          ) and
          t.getSize() = getSize()
        |
          t.getName()
        )
    }
  }

  /**
   * Gets the canonical integral type for the `IntegralType` `it`.
   */
  CanonicalIntegralType getCanonicalIntegralType(IntegralType it) {
    result.getSize() = it.getSize() and
    (
      it.isSigned() and result.isExplicitlySigned()
      or
      it.isUnsigned() and result.isExplicitlyUnsigned()
    )
  }

  private predicate isFundamentalTypeConstant(float value) {
    exists(BitField bf | value = 2.pow(8 * bf.getNumBits()) - 1)
    or
    value = any(Expr e).getValue().toFloat()
  }

  /**
   * Gets the fundamental type that can represent the value of `value`.
   */
  cached
  private CanonicalIntegralType getFundamentalType(float value) {
    isFundamentalTypeConstant(value) and
    exists(float lb, float ub, float limit |
      (
        lb = 0 and ub = limit - 1 and result.isUnsigned()
        or
        lb = -(limit / 2) and ub = (limit / 2) - 1 and result.isSigned()
      ) and
      result.getSize() =
        min(int size |
          size = [1, 2, 4, 8, 16] and limit = 2.pow(8 * size) and value >= lb and value <= ub
        )
    )
  }

  /**
   * Gets the smallest fundamental type that can represent the value of `value`.
   * Note that the smallest fundamental type is not necessarily unique.
   * For example, the value 1 can be represented by both an unsigned char and a signed char.
   */
  private CanonicalIntegralType getSmallestFundamentalType(float value) {
    isFundamentalTypeConstant(value) and
    result = min(CanonicalIntegralType t | t = getFundamentalType(value) | t order by t.getSize())
  }

  /**
   * Gets the smallest integral type that can represent the value of the integer literal `n` and matches the literal's signedness.
   * Note that the smallest fundamental type for an integer literal is unique.
   */
  private CanonicalIntegralType getSmallestFundamentalTypeForLiteral(Literal n) {
    result = getSmallestFundamentalType(n.getValue().toFloat()) and
    if n.getConversion().getType().getUnderlyingType() instanceof IntegralType
    then
      // If this is immediately converted to an `IntegralType`, we consider the signedness of the
      // conversion when computing the fundamental type
      exists(IntegralType it | it = n.getConversion().getType().getUnderlyingType() |
        result.isUnsigned() and it.isUnsigned()
        or
        result.isSigned() and it.isSigned()
      )
    else (
      result.isUnsigned() and n.getType().getUnderlyingType().(IntegralType).isUnsigned()
      or
      result.isSigned() and n.getType().getUnderlyingType().(IntegralType).isSigned()
    )
  }

  /** Gets the underlying type of expression `e` as specified in the Misra C++:2008 standard. */
  cached
  Type getUnderlyingType(Expr e) {
    exists(Type candidateType |
      if exists(getUnderlyingTypeInternal(e))
      then candidateType = getUnderlyingTypeInternal(e)
      else candidateType = e.getUnderlyingType()
    |
      if candidateType instanceof IntegralType
      then result = getCanonicalIntegralType(candidateType)
      else result = candidateType
    )
  }

  private class BalanceableOperation extends BinaryOperation {
    BalanceableOperation() {
      this instanceof BinaryArithmeticOperation
      or
      this instanceof BitwiseAndExpr
      or
      this instanceof BitwiseOrExpr
      or
      this instanceof BitwiseXorExpr
    }

    /**
     * Holds if `left` and `right` are the already deduced underlying types for the left and right
     * arguments of this binary operation.
     */
    predicate hasUnderlyingTypesInternal(Type left, Type right) {
      left = getUnderlyingTypeInternalRecursive(getLeftOperand()) and
      right = getUnderlyingTypeInternalRecursive(getRightOperand())
    }

    /** Gets the underlying type if this represents an integeral constant. */
    CanonicalIntegralType getUnderlyingTypeConstant() {
      exists(float value |
        value = getValue().toFloat() and
        (value >= 0 implies result.(CanonicalIntegralType).isUnsigned()) and
        result = getSmallestFundamentalType(value)
      )
    }

    /**
     * If both the underlying types for the arguments are integrals, then this reports the
     * underlying type for those integrals.
     */
    CanonicalIntegralType getUnderlyingTypeForIntegrals() {
      exists(IntegralType op1, IntegralType op2 | hasUnderlyingTypesInternal(op1, op2) |
        result = getUnderlyingIntegralType(op1, op2)
      )
    }
  }

  /** A helper predicate */
  private CanonicalIntegralType getUnderlyingIntegralType(IntegralType op1, IntegralType op2) {
    result.getSize() = op1.getSize() and
    result.getSize() = op2.getSize() and
    (
      if
        op1.isUnsigned() or
        op2.isUnsigned()
      then result.isUnsigned()
      else result.isSigned()
    )
    or
    // or it is the largest integral type.
    (
      result = getCanonicalIntegralType(op1) and
      op1.getSize() > op2.getSize()
      or
      result = getCanonicalIntegralType(op2) and
      op2.getSize() > op1.getSize()
    )
  }

  /**
   *  Helper predicate used to avoid OOMing the CodeQL compiler by including too many if-then-else
   * cases in a single predicate.
   */
  private Type getUnderlyingTypeConversion_numerics(BalanceableOperation binop) {
    // The following define the underlying type conversions.
    exists(Type op1, Type op2 | binop.hasUnderlyingTypesInternal(op1, op2) |
      // If the expression is wholly compromised of integral types then the underlying type of the expression
      // is the smallest fundamental type of the appropiate sign required to store the value.
      if exists(binop.getUnderlyingTypeConstant())
      then result = binop.getUnderlyingTypeConstant()
      else
        // If both operands have integeral type then
        if op1 instanceof IntegralType and op2 instanceof IntegralType
        then result = binop.getUnderlyingTypeForIntegrals()
        else
          if
            op1 instanceof FloatingPointType or
            op2 instanceof FloatingPointType
          then
            // Otherwise, if one of the operands has floating point type and the other an integral type
            // then the result is the floating point type.
            (
              result = op1 and
              op1 instanceof FloatingPointType and
              op2 instanceof IntegralType
              or
              result = op2 and
              op2 instanceof FloatingPointType and
              op1 instanceof IntegralType
            )
            or
            // Otherwise, if both operands have floating point type then the result is the largest type.
            result =
              max(FloatingPointType largestType |
                largestType = op1 or largestType = op2
              |
                largestType order by largestType.getSize()
              )
          else
            // If none of the other cases apply we return the type of the expression.
            result = binop.getUnderlyingType()
    )
  }

  private Type getUnderlyingTypeConversion(BalanceableOperation binop) {
    // The following define the underlying type conversions.
    exists(Type op1, Type op2 | binop.hasUnderlyingTypesInternal(op1, op2) |
      // If either operand has a char type (not explicitly signed or unsigned) then the underlying type of the expression is char type.
      if
        op1 instanceof PlainCharType
        or
        op2 instanceof PlainCharType
      then result instanceof PlainCharType
      else
        // If either operand has enum type then the underlying type of the expression is enum type.
        if op1 instanceof Enum or op2 instanceof Enum
        then if op1 instanceof Enum then result = op1 else result = op2
        else
          // If either operand has pointer type then the underlying type of the expression is pointer type.
          if
            op1 instanceof PointerType or
            op2 instanceof PointerType
          then
            // With a special consideration for substracting two pointers. Then the underlying type is `ptrdiff_t`
            if binop instanceof PointerDiffExpr
            then result instanceof Ptrdiff_t
            else
              if op1 instanceof PointerType
              then result = op1
              else result = op2
          else
            // If either operand has boolean type then the underlying type of the expression is boolean type.
            if
              op1 instanceof BoolType or
              op2 instanceof BoolType
            then result instanceof BoolType
            else result = getUnderlyingTypeConversion_numerics(binop)
    )
  }

  // Non-recursive underlying type calculation
  private Type getUnderlyingTypeSimple(Expr e) {
    // The underlying type of an integer literal will be determined by its
    // magnitude and signedness.
    result = getSmallestFundamentalTypeForLiteral(e)
    or
    result = e.(VariableAccess).getUnderlyingType()
    or
    // The underlying type of the result is the underlying type of the array element.
    result = e.(ArrayExpr).getUnderlyingType()
    or
    // The underlying type of a call is the underlying type of the return type.
    exists(Call call | e = call and not call.getTarget() instanceof UserOverloadedOperator |
      result = e.(Call).getUnderlyingType()
    )
    or
    // The underlying type of ! cast-expression is bool.
    e instanceof NotExpr and
    result instanceof BoolType
    or
    // The underlying type of relational operators is bool.
    e instanceof RelationalOperation and
    result instanceof BoolType
    or
    // The underlying type of equality operators is bool.
    e instanceof EqualityOperation and
    result instanceof BoolType
    or
    // The underlying type of logical AND and OR is bool.
    e instanceof BinaryLogicalOperation and
    result instanceof BoolType
    or
    // The underlying type of the conditional operator is bool.
    e instanceof ConditionalExpr and
    result instanceof BoolType
    or
    // The underlying type of a class type operand that is implicitly converted to a built-in type
    // is the type after the implicit conversion.
    exists(Conversion c |
      c = e and
      c.getExpr().getUnderlyingType() instanceof Class and
      c.getUnderlyingType() instanceof BuiltInType
    |
      result = c.getUnderlyingType()
    )
    or
    // The underlying type of a bit-field object is equivalent to an integral type the same signedness and size determined by
    // the width of the bit-field.
    e instanceof FieldAccess and
    e.(FieldAccess).getTarget() instanceof BitField and
    exists(BitField f, float limit |
      f.getAnAccess() = e and
      limit = 2.pow(8 * f.getNumBits()) - 1 and
      result = getSmallestFundamentalType(limit) and
      (
        result.(CanonicalIntegralType).isUnsigned() and
        f.getType().(IntegralType).isUnsigned()
        or
        result.(CanonicalIntegralType).isSigned() and
        f.getType().(IntegralType).isSigned()
      )
    )
    or
    // In the case when an overloaded operator is called, the underlying type of the expression
    // is the underlying type of the return.
    e instanceof Call and
    e.(Call).getTarget() instanceof UserOverloadedOperator and
    exists(UserOverloadedOperator op | op.getACallToThisFunction() = e |
      result = getSmallestFundamentalType(op.getACallToThisFunction().getValue().toFloat()) and
      (
        op.getType().getUnderlyingType() instanceof IntegralType
        implies
        (
          result.(CanonicalIntegralType).isUnsigned() and
          op.getType().getUnderlyingType().(IntegralType).isUnsigned()
          or
          result.(CanonicalIntegralType).isSigned() and
          op.getType().getUnderlyingType().(IntegralType).isSigned()
        )
      )
      or
      not exists(op.getACallToThisFunction().getValue()) and
      result = op.getType().getUnderlyingType()
    )
  }

  private Type getUnderlyingTypeInternalRecursive(Expr e) {
    if exists(Cast c | c = e.getConversion() and not c.isImplicit())
    then
      // The underlying type of a cast is the underlying type of the type-id.
      // For example, static_cast<type-id>(expression).
      exists(Cast cast | e.getConversion() = cast and not cast.isImplicit() |
        result = cast.getUnderlyingType()
      )
    else result = getUnderlyingTypeInternal(e)
  }

  private Type getUnderlyingTypeInternal(Expr e) {
    result = getUnderlyingTypeSimple(e)
    or
    // The result of the postfix increment or decrement is a cvalue expression whose underlying type is that of the
    // postfix expression.
    result = getUnderlyingTypeInternalRecursive(e.(PostfixCrementOperation).getAnOperand())
    or
    // The underlying type of the expressions:
    // ++ cast-expression, -- cast-expression, ~ cast-expression, and - cast-expression
    // is the underlying type of the cast-expression.
    exists(UnaryOperation unop | e = unop and not unop instanceof NotExpr |
      result = getUnderlyingTypeInternalRecursive(unop.getAnOperand())
    )
    or
    // The underlying type of the result is the underlying type of the shift expression.
    // shift-expression (<<|>>) additive-expression
    exists(BinaryBitwiseOperation shift |
      e = shift and
      (shift instanceof LShiftExpr or shift instanceof RShiftExpr)
    |
      result = getUnderlyingTypeInternalRecursive(shift.getLeftOperand())
    )
    or
    // The underlying type of the assignment operators is the underlying type of the `logical-or-expression` in
    // `logical-or-expression assignment-operator assignment-expression`
    exists(Assignment a | e = a | result = getUnderlyingTypeInternalRecursive(a.getLValue()))
    or
    // The underlying type of the comma operator is the `assignment-expression` in
    // `expression , assignment-expression`
    exists(CommaExpr commaExpr | e = commaExpr |
      result = getUnderlyingTypeInternalRecursive(commaExpr.getRightOperand())
    )
    or
    result = getUnderlyingTypeConversion(e)
  }
}
