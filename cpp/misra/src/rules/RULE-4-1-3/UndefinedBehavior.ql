/**
 * @id cpp/misra/undefined-behavior
 * @name RULE-4-1-3: There shall be no occurrence of undefined behaviour
 * @description It is not possible to reason about the behaviour of any program that contains
 *              instances of undefined behaviour, which can cause unpredictable results that are
 *              particularly difficult to detect during testing.
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
  not isExcluded(x, UndefinedPackage::undefinedBehaviorQuery()) and
select
