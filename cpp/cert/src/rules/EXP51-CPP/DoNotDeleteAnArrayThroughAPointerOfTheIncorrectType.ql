/**
 * @id cpp/cert/do-not-delete-an-array-through-a-pointer-of-the-incorrect-type
 * @name EXP51-CPP: Do not delete an array through a pointer of the incorrect type
 * @description Deleting an array through a pointer of an incorrect type leads to undefined
 *              behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp51-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.donotdeleteanarraythroughapointeroftheincorrecttypeshared.DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeShared

module DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeConfig implements
  DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeSharedConfigSig
{
  Query getQuery() {
    result = FreedPackage::doNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeQuery()
  }
}

module Shared =
  DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeShared<DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeConfig>;

import Shared::PathGraph
import Shared
