import cpp
import codingstandards.cpp.misra

/**
 * The signedness of a numeric type.
 */
newtype Signedness =
  Signed() or
  Unsigned()

/**
 * The type category of a numeric type - either integral or floating-point.
 */
newtype TypeCategory =
  Integral() or
  FloatingPoint()

/**
 * A numeric type is a type that represents a number, either an integral or a floating-point.
 *
 * In addition to the basic integral and floating-point types, it includes:
 * - Enum types with an explicit underlying type that is a numeric type.
 * - Typedef'd types that are numeric types.
 * - Numeric types with specifiers (e.g., `const`, `volatile`, `restrict`).
 */
class NumericType extends Type {
  Type realType;

  NumericType() {
    realType = this.getUnspecifiedType().(ReferenceType).getBaseType().(NumericType).getRealType() or
    realType = this.getUnspecifiedType().(IntegralType) or
    realType = this.getUnspecifiedType().(FloatingPointType) or
    realType = this.getUnspecifiedType().(Enum).getExplicitUnderlyingType().getUnspecifiedType()
  }

  Signedness getSignedness() {
    if realType.(IntegralType).isUnsigned() then result = Unsigned() else result = Signed()
  }

  /** Gets the size of the actual numeric type */
  int getRealSize() { result = realType.getSize() }

  TypeCategory getTypeCategory() {
    realType instanceof IntegralType and result = Integral()
    or
    realType instanceof FloatingPointType and result = FloatingPoint()
  }

  float getUpperBound() { result = typeUpperBound(realType) }

  float getLowerBound() { result = typeLowerBound(realType) }

  Type getRealType() { result = realType }
}

predicate isAssignment(Expr source, NumericType targetType, string context) {
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
    else targetType = assign.getLValue().getType()
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
}

/**
 * Gets the smallest integral type that can hold the value of a bit field.
 *
 * The type is determined by the signedness of the bit field and the number of bits.
 */
NumericType getBitFieldType(BitField bf) {
  exists(NumericType bitfieldActualType |
    bitfieldActualType = bf.getType() and
    // Integral type with the same signedness as the bit field, and big enough to hold the bit field value
    result instanceof IntegralType and
    result.getSignedness() = bitfieldActualType.getSignedness() and
    result.getSize() * 8 >= bf.getNumBits() and
    // No smaller integral type can hold the bit field value
    not exists(IntegralType other |
      other.getSize() * 8 >= bf.getNumBits() and
      other.(NumericType).getSignedness() = result.getSignedness() and
      other.getSize() < result.getRealSize()
    )
  )
}

/**
 * Holds if the `source` expression is assigned to a bit field.
 */
predicate isAssignedToBitfield(Expr source, BitField bf) {
  exists(Assignment assign |
    assign.getRValue() = source and
    assign.getLValue() = bf.getAnAccess()
  )
}
