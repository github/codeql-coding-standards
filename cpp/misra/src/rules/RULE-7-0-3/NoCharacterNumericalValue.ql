/**
 * @id cpp/misra/no-character-numerical-value
 * @name RULE-7-0-3: The numerical value of a character shall not be used
 * @description Using the numerical value of a character type may lead to inconsistent behavior due
 *              to encoding dependencies and should be avoided in favor of safer C++ Standard
 *              Library functions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-0-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra.BuiltInTypeRules

from Conversion c, Expr expr, Type sourceType, Type targetType
where
  expr = c.getExpr() and
  sourceType = expr.getType() and
  targetType = c.getType() and
  (
    // Conversion from character type to non-character type
    sourceType instanceof CharacterType and
    not targetType instanceof CharacterType
    or
    // Conversion from non-character type to character type
    not sourceType instanceof CharacterType and
    targetType instanceof CharacterType
  ) and
  // Exclude conversions where both operands have the same character type in equality operations
  not exists(EqualityOperation eq, CharacterType leftType, CharacterType rightType |
    eq.getAnOperand() = expr and
    leftType = eq.getLeftOperand().getType() and
    rightType = eq.getRightOperand().getType() and
    leftType.getRealType() = rightType.getRealType()
  ) and
  // Exclude unevaluated operands
  not expr.isUnevaluated()
select expr,
  "Conversion of character type '" + sourceType.getName() + "' to '" + targetType.getName() +
    "' uses numerical value of character."
