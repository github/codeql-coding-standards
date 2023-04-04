/**
 * A module for identifying essential types as defined by MISRA C 2012.
 */

import codingstandards.c.misra
import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils
import MisraExpressions

newtype TEssentialTypeCategory =
  EssentiallyBooleanType() or
  EssentiallyCharacterType() or
  EssentiallyEnumType() or
  EssentiallySignedType() or
  EssentiallyUnsignedType() or
  EssentiallyFloatingType()

/** An essential type category, as specified by Appendix D.1. */
class EssentialTypeCategory extends TEssentialTypeCategory {
  string toString() {
    this = EssentiallyBooleanType() and result = "essentially Boolean type"
    or
    this = EssentiallyCharacterType() and result = "essentially Character type"
    or
    this = EssentiallyEnumType() and result = "essentially Enum Type"
    or
    this = EssentiallySignedType() and result = "essentially Signed type"
    or
    this = EssentiallyUnsignedType() and result = "essentially Unsigned type"
    or
    this = EssentiallyFloatingType() and result = "essentially Floating type"
  }
}

/**
 * Gets the unsigned type of lowest rank that can represent the value of the given expression,
 * assuming that the expression is essentially unsigned.
 */
private IntegralType utlr(Expr const) {
  getEssentialTypeCategory(const.getType()) = EssentiallyUnsignedType() and
  getEssentialTypeCategory(result) = EssentiallyUnsignedType() and
  exists(float c | c = const.getValue().toFloat() |
    // As with range analysis, we assume two's complement representation
    typeLowerBound(result) <= c and
    typeUpperBound(result) >= c and
    forall(IntegralType it |
      getEssentialTypeCategory(it) = EssentiallyUnsignedType() and
      typeLowerBound(it) <= c and
      typeUpperBound(it) >= c
    |
      result.getSize() <= it.getSize()
    )
  )
}

/**
 * Gets the signed type of lowest rank that can represent the value of the given expression,
 * assuming that the expression is essentially signed.
 */
private IntegralType stlr(Expr const) {
  getEssentialTypeCategory(const.getType()) = EssentiallySignedType() and
  getEssentialTypeCategory(result) = EssentiallySignedType() and
  exists(float c | c = const.getValue().toFloat() |
    // As with range analysis, we assume two's complement representation
    typeLowerBound(result) <= c and
    typeUpperBound(result) >= c and
    forall(IntegralType it |
      getEssentialTypeCategory(it) = EssentiallySignedType() and
      typeLowerBound(it) <= c and
      typeUpperBound(it) >= c
    |
      result.getSize() <= it.getSize()
    )
  )
}

/**
 * Define the essential type category for an essentialType or a typedef of an essentialType.
 */
EssentialTypeCategory getEssentialTypeCategory(Type type) {
  exists(Type essentialType |
    if type instanceof MisraBoolType
    then essentialType = type
    else
      // If not a bool type, resolve the typedefs to determine the actual type
      essentialType = type.getUnspecifiedType()
  |
    result = EssentiallyBooleanType() and essentialType instanceof MisraBoolType
    or
    result = EssentiallyCharacterType() and essentialType instanceof PlainCharType
    or
    result = EssentiallySignedType() and
    essentialType.(IntegralType).isSigned() and
    not essentialType instanceof PlainCharType
    or
    result = EssentiallyUnsignedType() and
    essentialType.(IntegralType).isUnsigned() and
    not essentialType instanceof PlainCharType
    or
    result = EssentiallyEnumType() and
    essentialType instanceof Enum and
    not essentialType instanceof MisraBoolType
    or
    result = EssentiallyFloatingType() and
    essentialType instanceof FloatingPointType
  )
}

/**
 * Gets the essential type of the given expression `e`, considering any explicit conversions.
 */
Type getEssentialType(Expr e) {
  if e.hasExplicitConversion()
  then
    if e.getConversion() instanceof ParenthesisExpr
    then
      if e.getConversion().(ParenthesisExpr).hasExplicitConversion()
      then result = e.getConversion().(ParenthesisExpr).getConversion().getType()
      else result = e.getConversion().(ParenthesisExpr).getExpr().(EssentialExpr).getEssentialType()
    else result = e.getConversion().getType()
  else result = e.(EssentialExpr).getEssentialType()
}

Type getEssentialTypeBeforeConversions(Expr e) { result = e.(EssentialExpr).getEssentialType() }

class EssentialExpr extends Expr {
  Type getEssentialType() { result = this.getType() }

  Type getStandardType() { result = this.getType() }
}

class EssentialCommaExpr extends EssentialExpr, CommaExpr {
  override Type getEssentialType() { result = getEssentialType(getRightOperand()) }
}

class EssentialRelationalOperationExpr extends EssentialExpr, RelationalOperation {
  override Type getEssentialType() { result instanceof BoolType }
}

class EssentialBinaryLogicalOperationExpr extends EssentialExpr, BinaryLogicalOperation {
  override Type getEssentialType() { result instanceof BoolType }
}

class EssentialEqualityOperationExpr extends EssentialExpr, EqualityOperation {
  override Type getEssentialType() { result instanceof BoolType }
}

class EssentialBinaryBitwiseOperationExpr extends EssentialExpr, BinaryBitwiseOperation {
  EssentialBinaryBitwiseOperationExpr() {
    this instanceof LShiftExpr or
    this instanceof RShiftExpr
  }

  override Type getEssentialType() {
    exists(Type operandEssentialType, EssentialTypeCategory operandEssentialTypeCategory |
      operandEssentialType = getEssentialType(getLeftOperand()) and
      operandEssentialTypeCategory = getEssentialTypeCategory(operandEssentialType)
    |
      if operandEssentialTypeCategory instanceof EssentiallyUnsignedType
      then
        if exists(this.getValue())
        then result = utlr(this) // If constant and essentially unsigned us the utlr
        else result = operandEssentialType
      else result = this.getStandardType()
    )
  }
}

class EssentialBitwiseComplementExpr extends EssentialExpr, ComplementExpr {
  override Type getEssentialType() {
    exists(Type operandEssentialType, EssentialTypeCategory operandEssentialTypeCategory |
      operandEssentialType = getEssentialType(getOperand()) and
      operandEssentialTypeCategory = getEssentialTypeCategory(operandEssentialType)
    |
      if operandEssentialTypeCategory instanceof EssentiallyUnsignedType
      then
        if exists(this.getValue())
        then result = utlr(this) // If constant and essentially unsigned us the utlr
        else result = operandEssentialType
      else result = this.getStandardType()
    )
  }
}

class EssentialUnaryPlusExpr extends EssentialExpr, UnaryPlusExpr {
  override Type getEssentialType() {
    exists(Type operandEssentialType, EssentialTypeCategory operandEssentialTypeCategory |
      operandEssentialType = getEssentialType(getOperand()) and
      operandEssentialTypeCategory = getEssentialTypeCategory(operandEssentialType)
    |
      if
        operandEssentialTypeCategory =
          [EssentiallyUnsignedType().(TEssentialTypeCategory), EssentiallySignedType()]
      then result = operandEssentialType
      else result = getStandardType()
    )
  }
}

class EssentialUnaryMinusExpr extends EssentialExpr, UnaryMinusExpr {
  override Type getEssentialType() {
    exists(Type operandEssentialType, EssentialTypeCategory operandEssentialTypeCategory |
      operandEssentialType = getEssentialType(getOperand()) and
      operandEssentialTypeCategory = getEssentialTypeCategory(operandEssentialType)
    |
      if operandEssentialTypeCategory = EssentiallySignedType()
      then if exists(this.getValue()) then result = stlr(this) else result = operandEssentialType
      else result = getStandardType()
    )
  }
}

class EssentialConditionalExpr extends EssentialExpr, ConditionalExpr {
  override Type getEssentialType() {
    exists(Type thenEssentialType, Type elseEssentialType |
      thenEssentialType = getEssentialType(getThen()) and
      elseEssentialType = getEssentialType(getElse())
    |
      if thenEssentialType = elseEssentialType
      then result = thenEssentialType
      else
        if
          getEssentialTypeCategory(thenEssentialType) = EssentiallySignedType() and
          getEssentialTypeCategory(elseEssentialType) = EssentiallySignedType()
        then
          if thenEssentialType.getSize() > elseEssentialType.getSize()
          then result = thenEssentialType
          else result = elseEssentialType
        else
          if
            getEssentialTypeCategory(thenEssentialType) = EssentiallyUnsignedType() and
            getEssentialTypeCategory(elseEssentialType) = EssentiallyUnsignedType()
          then
            if thenEssentialType.getSize() > elseEssentialType.getSize()
            then result = thenEssentialType
            else result = elseEssentialType
          else result = this.getStandardType()
    )
  }
}

class EssentialBinaryArithmeticExpr extends EssentialExpr, BinaryArithmeticOperation {
  EssentialBinaryArithmeticExpr() {
    // GNU C extension has min/max which we can ignore
    not this instanceof MinExpr and
    not this instanceof MaxExpr
  }

  override Type getEssentialType() {
    exists(
      Type leftEssentialType, Type rightEssentialType,
      EssentialTypeCategory leftEssentialTypeCategory,
      EssentialTypeCategory rightEssentialTypeCategory
    |
      leftEssentialType = getEssentialType(getLeftOperand()) and
      rightEssentialType = getEssentialType(getRightOperand()) and
      leftEssentialTypeCategory = getEssentialTypeCategory(leftEssentialType) and
      rightEssentialTypeCategory = getEssentialTypeCategory(rightEssentialType)
    |
      if
        leftEssentialTypeCategory = EssentiallySignedType() and
        rightEssentialTypeCategory = EssentiallySignedType()
      then
        if exists(getValue())
        then result = stlr(this)
        else (
          if leftEssentialType.getSize() > rightEssentialType.getSize()
          then result = leftEssentialType
          else result = rightEssentialType
        )
      else
        if
          leftEssentialTypeCategory = EssentiallyUnsignedType() and
          rightEssentialTypeCategory = EssentiallyUnsignedType()
        then
          if exists(getValue())
          then result = utlr(this)
          else (
            if leftEssentialType.getSize() > rightEssentialType.getSize()
            then result = leftEssentialType
            else result = rightEssentialType
          )
        else
          if
            this instanceof AddExpr and
            (
              leftEssentialTypeCategory = EssentiallyCharacterType()
              or
              rightEssentialTypeCategory = EssentiallyCharacterType()
            ) and
            (
              leftEssentialTypeCategory =
                [EssentiallySignedType(), EssentiallyUnsignedType().(TEssentialTypeCategory)]
              or
              rightEssentialTypeCategory =
                [EssentiallySignedType(), EssentiallyUnsignedType().(TEssentialTypeCategory)]
            )
            or
            this instanceof SubExpr and
            leftEssentialTypeCategory = EssentiallyCharacterType() and
            rightEssentialTypeCategory =
              [EssentiallySignedType(), EssentiallyUnsignedType().(TEssentialTypeCategory)]
          then result instanceof PlainCharType
          else result = this.getStandardType()
    )
  }
}

class EssentialEnumConstantAccess extends EssentialExpr, EnumConstantAccess {
  override Type getEssentialType() { result = getTarget().getDeclaringEnum() }
}

class EssentialLiteral extends EssentialExpr, Literal {
  override Type getEssentialType() {
    if this instanceof BooleanLiteral
    then result instanceof MisraBoolType
    else (
      if this.(CharLiteral).getCharacter().length() = 1
      then result instanceof PlainCharType
      else (
        getStandardType().(IntegralType).isSigned() and
        result = stlr(this)
        or
        not getStandardType().(IntegralType).isSigned() and
        result = utlr(this)
      )
    )
  }
}

/**
 * Holds if `rValue` is assigned to an object of type `lValueEssentialType`.
 *
 * Assignment is according to "Assignment" in Appendix J of MISRA C 2012, with the inclusion of a
 * special case for switch statements as specified for Rule 10.3 and Rule 10.6.
 */
predicate isAssignmentToEssentialType(Type lValueEssentialType, Expr rValue) {
  // Special case for Rule 10.3/ Rule 10.6.
  exists(SwitchCase sc |
    lValueEssentialType = sc.getSwitchStmt().getControllingExpr().getType() and
    rValue = sc.getExpr()
  )
  or
  exists(Assignment a |
    lValueEssentialType = a.getLValue().getType() and
    rValue = a.getRValue()
  )
  or
  exists(FunctionCall fc, int i |
    lValueEssentialType = fc.getTarget().getParameter(i).getType() and
    rValue = fc.getArgument(i)
  )
  or
  exists(Function f, ReturnStmt rs |
    lValueEssentialType = f.getType() and
    rs.getEnclosingFunction() = f and
    rValue = rs.getExpr()
  )
  or
  // Initializing a non-aggregate type
  exists(Initializer i |
    lValueEssentialType = i.getDeclaration().(Variable).getType() and
    rValue = i.getExpr()
  )
  or
  // Initializing an array
  exists(ArrayAggregateLiteral aal |
    lValueEssentialType = aal.getElementType() and
    rValue = aal.getAnElementExpr(_)
  )
  or
  // Initializing a struct or union
  exists(ClassAggregateLiteral cal, Field field |
    lValueEssentialType = field.getType() and
    rValue = cal.getAFieldExpr(field)
  )
}
