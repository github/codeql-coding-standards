/**
 * A module for representing expressions and related types defined in the MISRA C 2012 standard.
 */

import codingstandards.c.misra

/**
 * A `bool` type, either `stdbool.h` or a hand-coded bool type acceptable to MISRA C 2012.
 */
class MisraBoolType extends Type {
  MisraBoolType() {
    this instanceof BoolType
    or
    exists(Enum e | this = e |
      count(e.getAnEnumConstant()) = 2 and
      e.getEnumConstant(0).getName().toLowerCase() = ["false", "f"] and
      e.getEnumConstant(1).getName().toLowerCase() = ["true", "t"]
    )
    or
    exists(TypedefType t | this = t | t.getName().toLowerCase() = ["bool", "boolean"])
  }
}

/**
 * A boolean literal as defined by the C standard and acceptable to MISRA C 2012.
 */
class BooleanLiteral extends Literal {
  BooleanLiteral() {
    exists(MacroInvocation mi, int value, string macroName |
      macroName = mi.getMacroName() and mi.getExpr() = this and value = this.getValue().toInt()
    |
      macroName = "false" and value = 0
      or
      macroName = "true" and value = 1
    )
  }
}

/**
 * A composite operator as defined in MISRA C:2012 8.10.3.
 */
class CompositeOperator extends Expr {
  CompositeOperator() {
    // + - * / % + -
    this instanceof BinaryArithmeticOperation and
    not this instanceof MaxExpr and
    not this instanceof MinExpr
    or
    // << >> & ^ |
    this instanceof BinaryBitwiseOperation
    or
    // ~
    this instanceof ComplementExpr
    or
    exists(ConditionalExpr ce | ce = this |
      ce.getElse() instanceof CompositeExpression or ce.getThen() instanceof CompositeExpression
    )
  }
}

/**
 * A composite expression as defined in MISRA C:2012 8.10.3.
 */
class CompositeExpression extends Expr {
  CompositeExpression() {
    this instanceof CompositeOperator and
    // A non-constant expression that is the result of a composite operator
    not exists(this.getValue())
  }
}

/**
 * An operator on which the usual arithmetic conversions apply to the operands, as defined in MISRA
 * C:2012 6.3.1.8.
 */
class OperationWithUsualArithmeticConversions extends Expr {
  OperationWithUsualArithmeticConversions() {
    this instanceof BinaryOperation and
    not this instanceof LShiftExpr and
    not this instanceof RShiftExpr and
    not this instanceof LogicalAndExpr and
    not this instanceof LogicalOrExpr
    or
    this instanceof AssignArithmeticOperation
  }

  Expr getLeftOperand() {
    result = this.(BinaryOperation).getLeftOperand()
    or
    result = this.(AssignArithmeticOperation).getLValue()
  }

  Expr getRightOperand() {
    result = this.(BinaryOperation).getRightOperand()
    or
    result = this.(AssignArithmeticOperation).getRValue()
  }

  Expr getAnOperand() { result = this.getLeftOperand() or result = this.getRightOperand() }

  string getOperator() {
    result = this.(BinaryOperation).getOperator()
    or
    result = this.(AssignArithmeticOperation).getOperator()
  }
}
