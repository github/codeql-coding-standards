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
  // Assignment operator (but not compound assignment)
  exists(AssignExpr assign |
    assign.getRValue() = source and
    context = "assignment"
  |
    // TODO generalize to variable init (do we need this for bitfields?) and extract
    if isAssignedToBitfield(source, _)
    then
      exists(BitField bf |
        isAssignedToBitfield(source, bf) and
        // TODO integral after numeric?
        targetType.(IntegralType).(NumericType).getSignedness() =
          bf.getType().(NumericType).getSignedness() and
        // smallest integral type that can hold the bit field value
        targetType.getRealSize() * 8 >= bf.getNumBits() and
        not exists(IntegralType other |
          other.getSize() * 8 >= bf.getNumBits() and
          other.(NumericType).getSignedness() = targetType.getSignedness() and
          other.getSize() < targetType.getRealSize()
        )
      )
    else targetType = assign.getLValue().getType()
  )
  or
  // Variable initialization
  exists(Variable v, Initializer init |
    init.getExpr() = source and
    v.getInitializer() = init and
    targetType = v.getType() and
    context = "initialization"
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

predicate isAssignedToBitfield(Expr source, BitField bf) {
  exists(Assignment assign |
    assign.getRValue() = source and
    assign.getLValue() = bf.getAnAccess()
  )
}
