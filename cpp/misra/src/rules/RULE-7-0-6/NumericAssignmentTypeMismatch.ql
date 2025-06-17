/**
 * @id cpp/misra/numeric-assignment-type-mismatch
 * @name RULE-7-0-6: Assignment between numeric types shall be appropriate
 * @description Assignment between numeric types with different sizes, signedness, or type
 *              categories can lead to unexpected information loss, undefined behavior, or silent
 *              overload resolution changes.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-7-0-6
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

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

predicate isValidConstantAssignment(Expr source, NumericType targetType) {
  isAssignment(source, targetType, _) and
  // Source is an integer constant expression
  source.isConstant() and
  source.getType().(NumericType).getTypeCategory() = Integral() and
  exists(float val | val = source.getValue().toFloat() |
    // Bit field assignment: check if the value fits in the bit field
    exists(BitField bf, int numBits |
      isAssignedToBitfield(source, bf) and
      numBits = bf.getNumBits() and
      val >= 0 and
      val < 2.pow(numBits)
    )
    or
    // Regular assignment: check if the value fits in the target type range
    not isAssignedToBitfield(source, _) and
    targetType.getLowerBound() <= val and
    val <= targetType.getUpperBound()
  )
}

predicate isValidTypeMatch(NumericType sourceType, NumericType targetType) {
  // Same type category, signedness and size
  sourceType.getTypeCategory() = targetType.getTypeCategory() and
  sourceType.getSignedness() = targetType.getSignedness() and
  sourceType.getRealSize() = targetType.getRealSize()
}

predicate hasConstructorException(FunctionCall call) {
  exists(Constructor ctor, Class c |
    call.getTarget() = ctor and
    c = ctor.getDeclaringType() and
    // Constructor callable with single numeric argument
    ctor.getNumberOfParameters() = 1 and
    ctor.getParameter(0).getType() instanceof NumericType and
    // No other single-argument constructors except copy/move
    not exists(Constructor other |
      other.getDeclaringType() = c and
      other != ctor and
      other.getNumberOfParameters() = 1 and
      not other instanceof CopyConstructor and
      not other instanceof MoveConstructor
    )
  )
}

/**
 * An id-expression that has a numeric type.
 *
 * This is restricted to variable accesses, that are not explicitly qualified in any way.
 */
class IdExpression extends VariableAccess {
  IdExpression() {
    // Not a member variable access (no dot or arrow)
    (
      not exists(this.getQualifier())
      or
      // Member variable, but the qualifier is not explicit
      this.getQualifier().isCompilerGenerated()
    ) and
    // Not an id-expression if it's an explicit conversion
    not this.hasExplicitConversion()
  }
}

predicate isValidWidening(Expr source, NumericType sourceType, NumericType targetType) {
  isAssignment(source, targetType, _) and
  source.getType() = sourceType and
  // Same type category and signedness, source size smaller, source is id-expression or has constructor exception
  (
    source instanceof IdExpression or
    hasConstructorException(any(Call call | call.getAnArgument() = source))
  ) and
  sourceType.getTypeCategory() = targetType.getTypeCategory() and
  sourceType.getSignedness() = targetType.getSignedness() and
  sourceType.getRealSize() < targetType.getRealSize()
}

/**
 * A non-extensible call is a call that cannot be extended by adding new overloads.
 */
predicate isNonExtensible(Call c) {
  exists(NameQualifier qual | qual.getExpr() = c and c.getTarget() instanceof MemberFunction)
  or
  exists(c.getQualifier()) and not c.getQualifier().isCompilerGenerated()
  or
  c.getTarget() instanceof Operator
}

predicate isOverloadIndependent(Call call, Expr arg) {
  arg = call.getAnArgument() and
  (
    // Call through function pointer
    call instanceof ExprCall
    or
    isNonExtensible(call) and
    forall(Function target, Function overload, int i |
      target = call.getTarget() and
      (
        overload = target.getAnOverload()
        or
        // Instantiated function templates don't directly participate in overload resolution
        // so check the templates overloads
        overload = target.(FunctionTemplateInstantiation).getTemplate().getAnOverload()
      ) and
      overload.getNumberOfParameters() = call.getNumberOfArguments() and
      call.getArgument(i) = arg
    |
      // Check that the parameter types match
      overload.getParameter(i).getType().getUnspecifiedType() =
        target.getParameter(i).getType().getUnspecifiedType()
    )
  )
}

/**
 * Check if the source expression should have the same type as the target type.
 */
predicate shouldHaveSameType(Expr source) {
  exists(Call call |
    call.getAnArgument() = source and
    isAssignment(source, _, _) and
    not hasConstructorException(call)
  |
    not isOverloadIndependent(call, source)
    or
    // Passed as a varargs parameter
    exists(int i |
      call.getTarget().isVarargs() and
      call.getArgument(i) = source and
      // Argument is greater than the number of parameters
      call.getTarget().getNumberOfParameters() <= i
    )
  )
}

predicate isValidAssignment(Expr source, NumericType targetType, string context) {
  isAssignment(source, targetType, context) and
  exists(NumericType sourceType | sourceType = source.getType() |
    if shouldHaveSameType(source)
    then sourceType.getRealType() = targetType.getRealType()
    else (
      // Valid type match
      isValidTypeMatch(sourceType, targetType)
      or
      // Valid widening assignment
      isValidWidening(source, sourceType, targetType)
      or
      // Valid constant assignment (integer constants)
      isValidConstantAssignment(source, targetType)
    )
  )
}

from Expr source, NumericType sourceType, NumericType targetType, string context
where
  not isExcluded(source, ConversionsPackage::numericAssignmentTypeMismatchQuery()) and
  isAssignment(source, targetType, context) and
  // The assignment must be between numeric types
  sourceType = source.getType() and
  not isValidAssignment(source, targetType, context)
select source,
  "Assignment between incompatible numeric types from '" + sourceType.getName() + "' to '" +
    targetType.getName() + "'."
