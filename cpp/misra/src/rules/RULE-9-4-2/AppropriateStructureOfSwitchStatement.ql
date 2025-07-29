/**
 * @id cpp/misra/appropriate-structure-of-switch-statement
 * @name RULE-9-4-2: The structure of a switch statement shall be appropriate
 * @description A switch statement should have an appropriate structure with proper cases, default
 *              labels, and break statements to ensure clear control flow and prevent unintended
 *              fall-through behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-9-4-2
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/allocated-target/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, StatementsPackage::appropriateStructureOfSwitchStatementQuery()) and
select
