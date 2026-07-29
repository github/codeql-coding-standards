/**
 * @id cpp/misra/array-deleted-through-pointer-of-incorrect-type
 * @name RULE-4-1-3: Array deleted through pointer of incorrect type leads to undefined behavior
 * @description Deleting an array through a pointer of an incorrect type leads to undefined
 *              behavior.
 * @kind path-problem
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
import codingstandards.cpp.rules.donotdeleteanarraythroughapointeroftheincorrecttypeshared.DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeShared

module ArrayDeletedThroughPointerOfIncorrectTypeConfig implements
  DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeSharedConfigSig
{
  Query getQuery() { result = UndefinedPackage::arrayDeletedThroughPointerOfIncorrectTypeQuery() }
}

module Shared =
  DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeShared<ArrayDeletedThroughPointerOfIncorrectTypeConfig>;

import Shared::PathGraph
import Shared
