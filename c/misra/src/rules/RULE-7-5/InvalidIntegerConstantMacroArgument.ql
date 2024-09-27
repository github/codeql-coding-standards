/**
 * @id c/misra/invalid-integer-constant-macro-argument
 * @name RULE-7-5: The argument of an integer constant macro shall have an appropriate form
 * @description Integer constant macros should be given appropriate values for the size of the
 *              integer type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-5
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.IntegerConstantMacro
import codingstandards.cpp.Cpp14Literal
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

abstract class PossiblyNegativeLiteral extends Expr {
  abstract Cpp14Literal::IntegerLiteral getBaseLiteral();

  predicate isNegative() {
    this instanceof NegativeLiteral
  }
}

class NegativeLiteral extends PossiblyNegativeLiteral, UnaryMinusExpr {
  Cpp14Literal::IntegerLiteral literal;

  NegativeLiteral() {
    literal = getOperand()
  }

  override Cpp14Literal::IntegerLiteral getBaseLiteral() {
    result = literal
  }
}

class PositiveLiteral extends PossiblyNegativeLiteral, Cpp14Literal::IntegerLiteral {
  PositiveLiteral() {
    not exists(UnaryMinusExpr l | l.getOperand() = this)
  }

  override Cpp14Literal::IntegerLiteral getBaseLiteral() {
    result = this
  }
}

predicate validExpr(Expr expr) {
  expr instanceof PossiblyNegativeLiteral
}

predicate usesSuffix(MacroInvocation invoke) {
  invoke.getUnexpandedArgument(0).regexpMatch(".*[uUlL]")
}

predicate matchedSign(IntegerConstantMacro macro, PossiblyNegativeLiteral literal) {
  literal.isNegative() implies macro.isSigned()
}

predicate validLiteralType(PossiblyNegativeLiteral expr) {
  expr.getBaseLiteral() instanceof Cpp14Literal::DecimalLiteral or
  expr.getBaseLiteral() instanceof Cpp14Literal::OctalLiteral or
  expr.getBaseLiteral() instanceof Cpp14Literal::HexLiteral
}

predicate matchesSize(IntegerConstantMacro macro, PossiblyNegativeLiteral literal) {
  // Note: upperBound should equal lowerBound.
  upperBound(literal) <= macro.maxValue() and
  lowerBound(literal) >= macro.minValue() and exists("123".toBigInt())
}

from MacroInvocation invoke, IntegerConstantMacro macro, string explanation
where
  not isExcluded(invoke, Types2Package::invalidIntegerConstantMacroArgumentQuery()) and
  invoke.getMacro() = macro and
  (
    (not validExpr(invoke.getExpr()) and explanation = "invalid expression") or
    (validLiteralType(invoke.getExpr()) and explanation = "invalid literal type" + invoke.getExpr().getAQlClass()) or
    (usesSuffix(invoke) and explanation = "literal suffixes not allowed") or
    (not matchedSign(macro, invoke.getExpr()) and explanation = "signed/unsigned mismatch") or
    (not matchesSize(macro, invoke.getExpr()) and explanation  = "invalid size")
  )
  
select invoke.getExpr(), "Invalid integer constant macro: " + explanation
