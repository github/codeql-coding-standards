/**
 * @id cpp/misra/no-standalone-type-cast-expression
 * @name RULE-9-2-1: An explicit type conversion shall not be an expression statement
 * @description Using an explicit type conversion as an expression statement creates a temporary
 *              object that is immediately discarded, which can lead to unintended premature
 *              resource cleanup.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-2-1
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from ExprStmt stmt, Expr expr
where
  not isExcluded(stmt, Conversions2Package::noStandaloneTypeCastExpressionQuery()) and
  expr = stmt.getExpr() and
  (
    // Explicit conversions which call a constructor
    expr instanceof ConstructorCall
    or
    // Cast expressions using functional notation
    expr instanceof Cast
  ) and
  // Exclude init-statements in if/for statements
  // This is because the extractor has a bug as of 2.20.7 which means it does not parse
  // these two cases separately. We choose to ignore if statements, which can cause false
  // negatives, but will prevent false positives
  not exists(IfStmt ifStmt | ifStmt.getInitialization() = stmt)
select stmt,
  "Explicit type conversion used as expression statement creates temporary object that is immediately discarded."
