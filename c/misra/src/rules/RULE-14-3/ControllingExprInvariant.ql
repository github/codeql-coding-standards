/**
 * @id c/misra/controlling-expr-invariant
 * @name RULE-14-3: Controlling expressions shall not be invariant
 * @description If a controlling expression has an invariant value then it is possible that there is
 *              a programming error.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-14-3
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes

from Expr expr, string message
where
  not isExcluded(expr, Statements5Package::controllingExprInvariantQuery()) and
  (
    exists(IfStmt ifStmt |
      (
        ifStmt.getControllingExpr() = expr and
        (
          conditionAlwaysFalse(expr)
          or
          conditionAlwaysTrue(expr)
        )
      )
    ) and
    message = "Controlling expression in if statement has invariant value."
    or
    exists(Loop loop |
      loop.getControllingExpr() = expr and
      (
        conditionAlwaysFalse(expr) and
        not (
          getEssentialTypeCategory(getEssentialType(expr)) instanceof EssentiallyBooleanType and
          expr.getValue() = "0"
        )
        or
        conditionAlwaysTrue(expr) and
        // Exception allows for infinite loops, but we only permit that for literals like `true`
        not expr instanceof Literal
      )
    ) and
    message = "Controlling expression in loop statement has invariant value."
    or
    exists(SwitchStmt switch |
      switch.getControllingExpr() = expr and
      (
        conditionAlwaysFalse(expr) or
        conditionAlwaysTrue(expr)
      )
    ) and
    message = "Controlling expression in switch statement has invariant value."
  ) and
  // Exclude cases where the controlling expressions is affected by a macro, because they can appear
  // invariant in a particular invocation, but be variant between invocations.
  not expr.isAffectedByMacro()
select expr, message
