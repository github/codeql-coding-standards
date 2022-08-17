/**
 * @id cpp/autosar/ternary-conditional-operator-used-as-sub-expression
 * @name A5-16-1: The ternary conditional operator shall not be used as a sub-expression
 * @description The ternary conditional operator shall not be used as a sub-expression or in a
 *              nested condition.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-16-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from ConditionalExpr c
where
  not isExcluded(c, BannedSyntaxPackage::ternaryConditionalOperatorUsedAsSubExpressionQuery()) and
  exists(Expr e |
    c.getParent() = e and
    not e.isAffectedByMacro()
  )
select c, "Use of ternary conditional operator as a sub-expression"
