/**
 * A library for utility classes related to the built-in type rules in MISRA C++ 2023 (Section 4.7.0).
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Call
import codingstandards.cpp.Type
import codingstandards.cpp.types.CanonicalTypes

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
    t instanceof PlainCharType or
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
 * Gets the built-in type of a type, if it is a built-in type.
 *
 * This function will strip specifiers and typedefs to get the underlying built-in type.
 */
BuiltInType getBuiltInType(Type t) {
  // Get the built-in type of a type, if it is a built-in type
  result = t
  or
  // Strip specifiers and typedefs to get the built-in type
  result = getBuiltInType(t.getUnspecifiedType())
  or
  // For reference types, get the base type and then the built-in type
  result = getBuiltInType(t.(ReferenceType).getBaseType())
  or
  // For enum types, get the explicit underlying type and then the built-in type
  result = getBuiltInType(t.(Enum).getExplicitUnderlyingType())
}

/**
 * The signedness of a MISRA C++ 2023 numeric type.
 */
newtype Signedness =
  Signed() or
  Unsigned()

class CharacterType extends Type {
  // The actual character type, which is either a plain char or a wide char
  BuiltInType realType;

  CharacterType() {
    // A type whose type category is character
    getTypeCategory(realType) = Character() and
    realType = getBuiltInType(this)
  }

  Type getRealType() { result = realType }
}

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
    // A type whose type category is either integral or a floating-point
    getTypeCategory(realType) = [Integral().(TypeCategory), FloatingPoint()] and
    realType = getBuiltInType(this)
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

predicate isSignedType(NumericType t) { t.getSignedness() = Signed() }

predicate isUnsignedType(NumericType t) { t.getSignedness() = Unsigned() }

/**
 * A canonical integer type for each unique size and signedness combination.
 *
 * Where multiple canonical arithmetic types exist for a given size/signedness combination, we
 * prefer the type with the shortest name.
 */
class CanonicalIntegerNumericType extends NumericType, CanonicalIntegralType {
  CanonicalIntegerNumericType() {
    // Where multiple types exist with the same size and signedness, prefer shorter names - mainly
    // to disambiguate between `unsigned long` and `unsigned long long` on platforms where they
    // are the same size
    this.isMinimal()
  }
}

predicate isAssignment(Expr source, Type targetType, string context) {
  exists(Expr preConversionAssignment |
    isPreConversionAssignment(preConversionAssignment, targetType, context) and
    preConversionAssignment.getExplicitlyConverted() = source
  )
}

predicate isPreConversionAssignment(Expr source, Type targetType, string context) {
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
    // A regular function call
    targetType = call.getTarget().getParameter(i).getType()
    or
    // A function call where the argument is passed as varargs
    call.getTarget().getNumberOfParameters() <= i and
    // The rule states that the type should match the "adjusted" type of the argument
    targetType = source.getFullyConverted().getType()
    or
    // An expression call - get the function type, then the parameter type
    targetType = getExprCallFunctionType(call).getParameterType(i)
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
CanonicalIntegerNumericType getBitFieldType(BitField bf) {
  exists(NumericType bitfieldActualType |
    bitfieldActualType = bf.getType() and
    // Integral type with the same signedness as the bit field, and big enough to hold the bit field value
    result.getSignedness() = bitfieldActualType.getSignedness() and
    result.getSize() * 8 >= bf.getNumBits() and
    // No smaller integral type can hold the bit field value
    not exists(CanonicalIntegerNumericType other |
      other.getSize() * 8 >= bf.getNumBits() and
      other.getSignedness() = result.getSignedness()
    |
      other.getSize() < result.getRealSize()
    )
  )
}

/**
 * Holds if the `source` expression is assigned to a bit field.
 */
predicate isAssignedToBitfield(Expr source, BitField bf) {
  source = bf.getAnAssignedValue().getExplicitlyConverted()
}
