/**
 * @id cpp/misra/undefined-behavior-audit
 * @name RULE-4-1-3: Audit: there shall be no occurrence of undefined behaviour
 * @description It is not possible to reason about the behaviour of any program that contains
 *              instances of undefined behaviour, which can cause unpredictable results that are
 *              particularly difficult to detect during testing.
 * @kind problem
 * @precision low
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/audit
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, UndefinedPackage::undefinedBehaviorAuditQuery()) and
select
