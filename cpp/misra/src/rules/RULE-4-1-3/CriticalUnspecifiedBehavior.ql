/**
 * @id cpp/misra/critical-unspecified-behavior
 * @name RULE-4-1-3: There shall be no occurrence of critical unspecified behaviour
 * @description Critical unspecified behaviour impacts the observable behaviour of the abstract
 *              machine and means a program is not guaranteed to behave predictably.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, UndefinedPackage::criticalUnspecifiedBehaviorQuery()) and
select
