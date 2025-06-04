/**
 * A module for identifying essential types as defined by MISRA C 2012.
 */

import codingstandards.c.misra
import semmle.code.cpp.rangeanalysis.RangeAnalysisUtils
import MisraExpressions

newtype TEssentialFloatCategory =
  Real() or
  Complex()

newtype TEssentialTypeCategory =
  EssentiallyBooleanType() or
  EssentiallyCharacterType() or
  EssentiallyEnumType() or
  EssentiallySignedType() or
  EssentiallyUnsignedType() or
  EssentiallyFloatingType(TEssentialFloatCategory c)

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
    this = EssentiallyFloatingType(Real()) and result = "essentially Floating type"
    or
    this = EssentiallyFloatingType(Complex()) and result = "essentially Complex Floating type"
  }
}

class EssentiallySignedOrUnsignedType extends EssentialTypeCategory {
  EssentiallySignedOrUnsignedType() {
    this = EssentiallySignedType() or this = EssentiallyUnsignedType()
  }
}

/**
 * An expression in the program that evaluates to a compile time constant signed or unsigned integer.
 */
private class ConstantIntegerExpr extends Expr {
  pragma[noinline]
  ConstantIntegerExpr() {
    getEssentialTypeCategory(this.getType()) instanceof EssentiallySignedOrUnsignedType and
    exists(this.getValue().toFloat()) and
    not this instanceof Conversion
  }
}

/** A `float` which represents an integer constant in the program. */
private class IntegerConstantAsFloat extends float {
  IntegerConstantAsFloat() { exists(ConstantIntegerExpr ce | this = ce.getValue().toFloat()) }
}

/**
 * Identifies which integral types from which type categories can represent a given integer constant
 * in the program.
 */
pragma[nomagic]
private predicate isCandidateIntegralType(
  EssentialTypeCategory cat, IntegralType it, IntegerConstantAsFloat c
) {
  getEssentialTypeCategory(it) = cat and
  c = any(ConstantIntegerExpr ce).getValue().toFloat() and
  // As with range analysis, we assume two's complement representation
  typeLowerBound(it) <= c and
  typeUpperBound(it) >= c
}

/**
 * Gets the unsigned type of lowest rank that can represent the value of the given expression,
 * assuming that the expression is essentially unsigned.
 */
pragma[nomagic]
private IntegralType utlr(ConstantIntegerExpr const) {
  getEssentialTypeCategory(const.getType()) = EssentiallyUnsignedType() and
  result = utlr_c(const.getValue().toFloat())
}

/**
 * Given an integer constant that appears in the program, gets the unsigned type of lowest rank
 * that can hold it.
 */
pragma[nomagic]
private IntegralType utlr_c(IntegerConstantAsFloat c) {
  isCandidateIntegralType(EssentiallyUnsignedType(), result, c) and
  forall(IntegralType it | isCandidateIntegralType(EssentiallyUnsignedType(), it, c) |
    result.getSize() <= it.getSize()
  )
}

/**
 * Gets the signed type of lowest rank that can represent the value of the given expression,
 * assuming that the expression is essentially signed.
 */
pragma[nomagic]
private IntegralType stlr(ConstantIntegerExpr const) {
  getEssentialTypeCategory(const.getType()) = EssentiallySignedType() and
  result = stlr_c(const.getValue().toFloat())
}

/**
 * Given an integer constant that appears in the program, gets the signed type of lowest rank
 * that can hold it.
 */
pragma[nomagic]
private IntegralType stlr_c(IntegerConstantAsFloat c) {
  isCandidateIntegralType(EssentiallySignedType(), result, c) and
  forall(IntegralType it | isCandidateIntegralType(EssentiallySignedType(), it, c) |
    result.getSize() <= it.getSize()
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
    // Anonymous enums are considered to be signed
    result = EssentiallySignedType() and
    essentialType instanceof AnonymousEnumType and
    not essentialType instanceof MisraBoolType
    or
    result = EssentiallyUnsignedType() and
    essentialType.(IntegralType).isUnsigned() and
    not essentialType instanceof PlainCharType
    or
    result = EssentiallyEnumType() and
    essentialType instanceof NamedEnumType and
    not essentialType instanceof MisraBoolType
    or
    result = EssentiallyFloatingType(Real()) and
    essentialType instanceof RealNumberType
    or
    result = EssentiallyFloatingType(Complex()) and
    essentialType instanceof ComplexNumberType
  )
}

/**
 * Gets the essential type of the given expression `e`, considering any explicit conversions.
 */
pragma[nomagic]
Type getEssentialType(Expr e) {
  if e.hasConversion()
  then result = getEssentialTypeOfConversion(e.getFullyConverted())
  else result = e.(EssentialExpr).getEssentialType()
}

Type getEssentialTypeOfConversion(Expr e) {
  if e.(Conversion).isImplicit() or e instanceof ParenthesisExpr or e instanceof C11GenericExpr
  then result = getEssentialTypeOfConversion(e.(Conversion).getExpr())
  else result = e.(EssentialExpr).getEssentialType()
}

Type getEssentialTypeBeforeConversions(Expr e) { result = e.(EssentialExpr).getEssentialType() }

/**
 * For most essential types, `Type.getSize()` is correct, except for complex floating types.
 *
 * For complex floating types, the size is the size of the real part, so we divide by 2.
 */
int getEssentialSize(Type essentialType) {
  if getEssentialTypeCategory(essentialType) = EssentiallyFloatingType(Complex())
  then result = essentialType.getSize() / 2
  else result = essentialType.getSize()
}

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

class EssentialUnaryLogicalOperationExpr extends EssentialExpr, UnaryLogicalOperation {
  override Type getEssentialType() { result instanceof BoolType }
}

class EssentialEqualityOperationExpr extends EssentialExpr, EqualityOperation {
  override Type getEssentialType() { result instanceof BoolType }
}

class EssentialShiftOperationExpr extends EssentialExpr, BinaryBitwiseOperation {
  EssentialShiftOperationExpr() {
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
      if operandEssentialTypeCategory instanceof EssentiallySignedOrUnsignedType
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

bindingset[essentialTypeA, essentialTypeB]
private Type maxRankType(Type essentialTypeA, Type essentialTypeB) {
  if essentialTypeA.getSize() > essentialTypeB.getSize()
  then result = essentialTypeA
  else result = essentialTypeB
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
          getEssentialTypeCategory(thenEssentialType) = getEssentialTypeCategory(elseEssentialType) and
          getEssentialTypeCategory(thenEssentialType) instanceof EssentiallySignedOrUnsignedType
        then result = maxRankType(thenEssentialType, elseEssentialType)
        else result = this.getStandardType()
    )
  }
}

/**
 * A binary operation subject to usual conversions, with essential type behaviour as specified by D.7.9.
 */
class EssentialBinaryOperationSubjectToUsualConversions extends EssentialExpr, BinaryOperation {
  EssentialBinaryOperationSubjectToUsualConversions() {
    this instanceof MulExpr
    or
    this instanceof DivExpr
    or
    this instanceof RemExpr
    or
    this instanceof AddExpr
    or
    this instanceof SubExpr
    or
    this instanceof BitwiseAndExpr
    or
    this instanceof BitwiseOrExpr
    or
    this instanceof BitwiseXorExpr
  }

  override Type getEssentialType() {
    exists(
      Type leftEssentialType, Type rightEssentialType,
      EssentialTypeCategory leftEssentialTypeCategory,
      EssentialTypeCategory rightEssentialTypeCategory, int intTypeSize
    |
      leftEssentialType = getEssentialType(getLeftOperand()) and
      rightEssentialType = getEssentialType(getRightOperand()) and
      leftEssentialTypeCategory = getEssentialTypeCategory(leftEssentialType) and
      rightEssentialTypeCategory = getEssentialTypeCategory(rightEssentialType) and
      // For rules around addition/subtraction with char types:
      intTypeSize = any(IntType i | i.isSigned()).getSize()
    |
      if
        leftEssentialTypeCategory = rightEssentialTypeCategory and
        leftEssentialTypeCategory instanceof EssentiallySignedOrUnsignedType
      then
        if exists(getValue())
        then
          leftEssentialTypeCategory = EssentiallySignedType() and result = stlr(this)
          or
          leftEssentialTypeCategory = EssentiallyUnsignedType() and result = utlr(this)
        else result = maxRankType(leftEssentialType, rightEssentialType)
      else result = this.getStandardType()
    )
  }
}

/**
 * An add expression, with essential type behaviour as specified by D.7.9.
 */
class EssentialAddExpr extends EssentialBinaryOperationSubjectToUsualConversions, AddExpr {
  override Type getEssentialType() {
    exists(
      Type otherOperandType, EssentialTypeCategory operandTypeCategory,
      EssentialTypeCategory otherOperandTypeCategory, int intTypeSize
    |
      operandTypeCategory = getEssentialTypeCategory(getEssentialType(getAnOperand())) and
      otherOperandType = getEssentialType(getAnOperand()) and
      otherOperandTypeCategory = getEssentialTypeCategory(otherOperandType) and
      intTypeSize = any(IntType i).getSize()
    |
      if
        operandTypeCategory = EssentiallyCharacterType() and
        otherOperandTypeCategory instanceof EssentiallySignedOrUnsignedType and
        otherOperandType.getSize() <= intTypeSize
      then result instanceof PlainCharType
      else result = super.getEssentialType()
    )
  }
}

/**
 * A sub expression, with essential type behaviour as specified by D.7.9.
 */
class EssentialSubExpr extends EssentialBinaryOperationSubjectToUsualConversions, SubExpr {
  override Type getEssentialType() {
    exists(
      EssentialTypeCategory leftEssentialTypeCategory, Type rightEssentialType,
      EssentialTypeCategory rightEssentialTypeCategory, int intTypeSize
    |
      leftEssentialTypeCategory = getEssentialTypeCategory(getEssentialType(getLeftOperand())) and
      rightEssentialType = getEssentialType(getRightOperand()) and
      rightEssentialTypeCategory = getEssentialTypeCategory(rightEssentialType) and
      intTypeSize = any(IntType i).getSize()
    |
      if
        leftEssentialTypeCategory = EssentiallyCharacterType() and
        rightEssentialTypeCategory instanceof EssentiallySignedOrUnsignedType and
        rightEssentialType.getSize() <= intTypeSize
      then result instanceof PlainCharType
      else result = super.getEssentialType()
    )
  }
}

/**
 * A named Enum type, as per D.5.
 */
class NamedEnumType extends Enum {
  NamedEnumType() {
    not isAnonymous()
    or
    exists(Type useOfEnum | this = useOfEnum.stripType() |
      exists(TypedefType t | t.getBaseType() = useOfEnum)
      or
      exists(Function f | f.getType() = useOfEnum or f.getAParameter().getType() = useOfEnum)
      or
      exists(Struct s | s.getAField().getType() = useOfEnum)
      or
      exists(Variable v | v.getType() = useOfEnum)
    )
  }
}

/**
 * An anonymous Enum type, as per D.5.
 */
class AnonymousEnumType extends Enum {
  AnonymousEnumType() { not this instanceof NamedEnumType }
}

/**
 * The EssentialType of an EnumConstantAccess, which may be essentially enum or essentially signed.
 */
class EssentialEnumConstantAccess extends EssentialExpr, EnumConstantAccess {
  override Type getEssentialType() {
    exists(Enum e | e = getTarget().getDeclaringEnum() |
      if e instanceof NamedEnumType then result = e else result = stlr(this)
    )
  }
}

class EssentialLiteral extends EssentialExpr, Literal {
  override Type getEssentialType() {
    if this instanceof BooleanLiteral
    then
      // This returns a multitude of types - not sure if we really want that
      result instanceof MisraBoolType
    else (
      if this instanceof CharLiteral
      then result instanceof PlainCharType
      else
        exists(Type underlyingStandardType |
          underlyingStandardType = getStandardType().getUnderlyingType()
        |
          if underlyingStandardType instanceof IntType
          then
            if underlyingStandardType.(IntType).isSigned()
            then result = stlr(this)
            else result = utlr(this)
          else result = getStandardType()
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
