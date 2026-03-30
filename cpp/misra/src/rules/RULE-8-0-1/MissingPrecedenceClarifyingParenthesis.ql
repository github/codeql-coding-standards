/**
 * @id cpp/misra/missing-precedence-clarifying-parenthesis
 * @name RULE-8-0-1: Parentheses should be used to make the meaning of an expression appropriately explicit
 * @description Usage of parentheses improve program clarity when using multiple operators of
 *              different precedences.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-0-1
 *       scope/single-translation-unit
 *       readability
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.AlertReporting

/**
 * MISRA operator precedence levels are not an exact match with standard C++ operator precedence,
 * and therefore defined in this class.
 *
 * For example, MISRA treats ternary, assigment, and throw operators as having separate precedence
 * levels, while in C++17 they all have the same precedence. Additionally, MISRA treats all
 * operators not in the list below as having the same precedence, while in C++17 some of the
 * remaining operators (*x, x[], x++, ++x) have different precedences than others.
 *
 * This list is defined in the MISRA specification.
 */
class MisraPrecedenceExpr instanceof Expr {
  int precedence;
  string operator;

  MisraPrecedenceExpr() {
    not super.isCompilerGenerated() and
    (
      operator = [this.(BinaryOperation).getOperator(), this.(Assignment).getOperator()]
      or
      this instanceof ConditionalExpr and operator = "?"
      or
      this instanceof ThrowExpr and operator = "throw"
    ) and
    (
      operator = ["*", "/", "%"] and precedence = 13
      or
      operator = ["+", "-"] and precedence = 12
      or
      operator = ["<<", ">>"] and precedence = 11
      or
      operator = ["<", "<=", ">", ">="] and precedence = 10
      or
      operator = ["==", "!="] and precedence = 9
      or
      operator = "&" and precedence = 8
      or
      operator = "^" and precedence = 7
      or
      operator = "|" and precedence = 6
      or
      operator = "&&" and precedence = 5
      or
      operator = "||" and precedence = 4
      or
      operator = ["=", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=", "<<=", ">>="] and
      precedence = 2
      or
      operator = "?" and precedence = 3
      or
      operator = "throw" and precedence = 1
    )
  }

  int getMisraPrecedence() { result = precedence }

  string getOperator() { result = operator }

  MisraPrecedenceExpr getAnExplicitlyConvertedChild() {
    result = super.getAChild().getExplicitlyConverted()
  }

  Element getElement() { result = MacroUnwrapper<Expr>::unwrapElement(this) }

  string toString() { result = super.toString() }
}

from MisraPrecedenceExpr parent, MisraPrecedenceExpr child
where
  not isExcluded(child, Expressions2Package::missingPrecedenceClarifyingParenthesisQuery()) and
  not parent.(Expr).isFromTemplateInstantiation(_) and
  parent.getAnExplicitlyConvertedChild() = child and
  parent.getMisraPrecedence() > 2 and
  parent.getMisraPrecedence() < child.getMisraPrecedence()
select child.getElement(),
  "Expression with operator '" + parent.getOperator() +
    "' contains an unparenthesized child expression with higher precedence operator '" +
    child.getOperator() + "'."
