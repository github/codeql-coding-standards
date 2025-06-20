/**
 * A library for utility classes related to the built-in type rules in MISRA C++ 2023 (Section 4.7.0).
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Type

/**
 * A MISRA C++ 2023 type category.
 */
newtype TypeCategory =
  Integral() or
  FloatingPoint() or
  Character() or
  Other()

/**
 * Gets the type category of a built-in type.
 *
 * This does not apply the rules related to stripping specifiers or typedefs, or references.
 */
TypeCategory getTypeCategory(BuiltInType t) {
  (
    t instanceof CharType or
    t instanceof WideCharType or
    t instanceof Char16Type or
    t instanceof Char32Type or
    t instanceof Char8Type
  ) and
  result = Character()
  or
  (
    // The 5 standard integral types, covering both signed/unsigned variants
    // Explicitly list the signed/unsigned `char` to avoid capturing plain `char`, which is of character type category
    t instanceof SignedCharType or
    t instanceof UnsignedCharType or
    t instanceof ShortType or
    t instanceof IntType or
    t instanceof LongType or
    t instanceof LongLongType
  ) and
  result = Integral()
  or
  (
    t instanceof FloatType or
    t instanceof DoubleType or
    t instanceof LongDoubleType
  ) and
  result = FloatingPoint()
  or
  (
    t instanceof BoolType or
    t instanceof VoidType or
    t instanceof NullPointerType
  ) and
  result = Other()
}

/**
 * The signedness of a MISRA C++ 2023 numeric type.
 */
newtype Signedness =
  Signed() or
  Unsigned()

/**
 * A MISRA C++ 2023 numeric type is a type that represents a number, either an integral or a floating-point.
 *
 * In addition to the basic integral and floating-point types, it includes:
 * - Enum types with an explicit underlying type that is a numeric type.
 * - Typedef'd types that are numeric types.
 * - Numeric types with specifiers (e.g., `const`, `volatile`, `restrict`).
 */
class NumericType extends Type {
  // The actual numeric type, which is either an integral or a floating-point type.
  Type realType;

  NumericType() {
    // A type which is either an integral or a floating-point type category
    getTypeCategory(this) = [Integral().(TypeCategory), FloatingPoint()] and
    realType = this
    or
    // Any type which, after stripping specifiers and typedefs, is a numeric type
    realType = this.getUnspecifiedType().(NumericType).getRealType()
    or
    // Any reference type where the base type is a numeric type
    realType = this.(ReferenceType).getBaseType().(NumericType).getRealType()
    or
    // Any Enum type with an explicit underlying type that is a numeric type
    realType = this.(Enum).getExplicitUnderlyingType().(NumericType).getRealType()
  }

  Signedness getSignedness() {
    if realType.(IntegralType).isUnsigned() then result = Unsigned() else result = Signed()
  }

  /** Gets the size of the actual numeric type. */
  int getRealSize() { result = realType.getSize() }

  TypeCategory getTypeCategory() { result = getTypeCategory(realType) }

  /**
   * Gets the integeral upper bound of the numeric type, if it represents an integer type.
   */
  QlBuiltins::BigInt getIntegralUpperBound() { integralTypeBounds(realType, _, result) }

  /**
   * Gets the integeral lower bound of the numeric type, if it represents an integer type.
   */
  QlBuiltins::BigInt getIntegralLowerBound() { integralTypeBounds(realType, result, _) }

  Type getRealType() { result = realType }
}

/**
 * One of the 10 canonical integer types, which are the standard integer types.
 */
class CanonicalIntegerTypes extends NumericType, IntegralType {
  CanonicalIntegerTypes() { this = this.getCanonicalArithmeticType() }
}

predicate isAssignment(Expr source, NumericType targetType, string context) {
  exists(Expr preConversionAssignment |
    isPreConversionAssignment(preConversionAssignment, targetType, context) and
    preConversionAssignment.getExplicitlyConverted() = source
  )
}

predicate isPreConversionAssignment(Expr source, NumericType targetType, string context) {
  // Assignment expression (which excludes compound assignments)
  exists(AssignExpr assign |
    assign.getRValue() = source and
    context = "assignment"
  |
    if isAssignedToBitfield(source, _)
    then
      // For the MISRA type rules we treat bit fields as a special case
      exists(BitField bf |
        isAssignedToBitfield(source, bf) and
        targetType = getBitFieldType(bf)
      )
    else
      exists(Type t | t = assign.getLValue().getType() |
        // Unwrap PointerToMemberType e.g `l1.*l2 = x;`
        if t instanceof PointerToMemberType
        then targetType = t.(PointerToMemberType).getBaseType()
        else targetType = t
      )
  )
  or
  // Variable initialization
  exists(Variable v, Initializer init |
    init.getExpr() = source and
    v.getInitializer() = init and
    context = "initialization"
  |
    // For the MISRA type rules we treat bit fields as a special case
    if v instanceof BitField
    then targetType = getBitFieldType(v)
    else
      // Regular variable initialization
      targetType = v.getType()
  )
  or
  exists(ConstructorFieldInit fi |
    fi.getExpr() = source and
    context = "constructor field initialization"
  |
    // For the MISRA type rules we treat bit fields as a special case
    if fi.getTarget() instanceof BitField
    then targetType = getBitFieldType(fi.getTarget())
    else
      // Regular variable initialization
      targetType = fi.getTarget().getType()
  )
  or
  // Passing a function parameter by value
  exists(Call call, int i |
    call.getArgument(i) = source and
    not targetType.stripTopLevelSpecifiers() instanceof ReferenceType and
    context = "function argument"
  |
    targetType = call.getTarget().getParameter(i).getType()
    or
    // Handle varargs - use the fully converted type of the argument
    call.getTarget().getNumberOfParameters() <= i and
    targetType = source.getFullyConverted().getType()
    or
    // A standard expression call
    targetType = call.(ExprCall).getExpr().getType().(FunctionPointerIshType).getParameterType(i)
    or
    // An expression call using the pointer to member operator (.* or ->*)
    // This special handling is required because we don't have a CodeQL class representing the call
    // to a pointer to member function, but the right hand side is extracted as the -1 child of the
    // call
    targetType =
      call.(ExprCall)
          .getChild(-1)
          .getType()
          .(PointerToMemberType)
          .getBaseType()
          .(RoutineType)
          .getParameterType(i)
  )
  or
  // Return statement
  exists(ReturnStmt ret, Function f |
    ret.getExpr() = source and
    ret.getEnclosingFunction() = f and
    targetType = f.getType() and
    not targetType.stripTopLevelSpecifiers() instanceof ReferenceType and
    context = "return"
  )
  or
  // Switch case
  exists(SwitchCase case, SwitchStmt switch |
    case.getExpr() = source and
    case.getSwitchStmt() = switch and
    targetType = switch.getExpr().getFullyConverted().getType() and
    context = "switch case"
  )
  or
  // Class aggregate literal initialization
  exists(ClassAggregateLiteral al, Field f |
    source = al.getAFieldExpr(f) and
    context = "class aggregate literal"
  |
    // For the MISRA type rules we treat bit fields as a special case
    if f instanceof BitField
    then targetType = getBitFieldType(f)
    else
      // Regular variable initialization
      targetType = f.getType()
  )
  or
  // Array or vector aggregate literal initialization
  exists(ArrayOrVectorAggregateLiteral vl |
    source = vl.getAnElementExpr(_) and
    targetType = vl.getElementType() and
    context = "array or vector aggregate literal"
  )
}

/**
 * Gets the smallest integral type that can hold the value of a bit field.
 *
 * The type is determined by the signedness of the bit field and the number of bits.
 */
CanonicalIntegerTypes getBitFieldType(BitField bf) {
  exists(NumericType bitfieldActualType |
    bitfieldActualType = bf.getType() and
    // Integral type with the same signedness as the bit field, and big enough to hold the bit field value
    result.getSignedness() = bitfieldActualType.getSignedness() and
    result.getSize() * 8 >= bf.getNumBits() and
    // No smaller integral type can hold the bit field value
    not exists(CanonicalIntegerTypes other |
      other.getSize() * 8 >= bf.getNumBits() and
      other.getSignedness() = result.getSignedness()
    |
      other.getSize() < result.getRealSize()
      or
      // Where multiple types exist with the same size and signedness, prefer shorter names - mainly
      // to disambiguate between `unsigned long` and `unsigned long long` on platforms where they
      // are the same size
      other.getSize() = result.getRealSize() and
      other.getName().length() < result.getName().length()
    )
  )
}

/**
 * Holds if the `source` expression is assigned to a bit field.
 */
predicate isAssignedToBitfield(Expr source, BitField bf) {
  source = bf.getAnAssignedValue().getExplicitlyConverted()
}
