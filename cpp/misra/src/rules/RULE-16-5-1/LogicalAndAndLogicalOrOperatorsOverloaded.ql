/**
 * @id cpp/misra/logical-and-and-logical-or-operators-overloaded
 * @name RULE-16-5-1: The logical AND and logical OR operators shall not be overloaded
 * @description Overloaded logical AND and logical OR operators change short-circuiting behavior and
 *              can lead to unexpected results.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-16-5-1
 *       scope/single-translation-unit
 *       correctness
 *       readability
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from Element element, string message
where
  not isExcluded(element, Classes2Package::logicalAndAndLogicalOrOperatorsOverloadedQuery()) and
  // Case 1: Overloaded logical operator definitions
  exists(Operator op |
    op = element and
    (op.getName() = "operator&&" or op.getName() = "operator||") and
    message =
      "Overloaded logical operator '" + op.getName() +
        "' changes short-circuit evaluation behavior."
  )
select element, message
