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
import codingstandards.cpp.ConstantExpressions
import codingstandards.cpp.misra.StandardConversions
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

predicate isValidConstantAssignment(IntegerConstantExpr source, NumericType targetType) {
  isAssignment(source, targetType, _) and
  exists(QlBuiltins::BigInt val | val = source.getConstantValue() |
    // Bit field assignment: check if the value fits in the bit field
    exists(BitField bf, int numBits |
      isAssignedToBitfield(source, bf) and
      numBits = bf.getNumBits() and
      if targetType.getSignedness() = Signed()
      then
        // Signed bit field: value must be in the range of signed bit field
        val >= -2.toBigInt().pow(numBits - 1) and
        val < 2.toBigInt().pow(numBits - 1)
      else (
        // Unsigned bit field: value must be in the range of unsigned bit field
        val >= 0.toBigInt() and
        val < 2.toBigInt().pow(numBits)
      )
    )
    or
    // Regular assignment: check if the value fits in the target type range
    not isAssignedToBitfield(source, _) and
    (
      // Integer types: check if the value fits in the target type range
      targetType.getIntegralLowerBound() <= val and
      val <= targetType.getIntegralUpperBound()
      or
      // All floating point types can represent all integer values
      targetType.getTypeCategory() = FloatingPoint()
    )
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

int getMinimumNumberOfParameters(Function f) {
  result = count(Parameter p | p = f.getAParameter() and not p.hasInitializer() | p)
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
      // Check that the overload accepts the number of arguments provided by this call,
      // considering parameters with default values may be omitted in the call
      overload.getNumberOfParameters() >= call.getNumberOfArguments() and
      getMinimumNumberOfParameters(overload) <= call.getNumberOfArguments() and
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
