/**
 * @id cpp/misra/possible-data-race-between-threads
 * @name RULE-4-1-3: Data races between threads lead to undefined behavior
 * @description Threads accessing the same memory location concurrently without utilization of
 *              thread synchronization objects results in undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       concurrency
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.lifetimes.CppObjects as CppObjects
import codingstandards.cpp.lifetimes.CppSubObjects as CppSubObjects
import codingstandards.cpp.rules.possibledataracebetweenthreadsshared.PossibleDataRaceBetweenThreadsShared

module PossibleDataRaceBetweenThreadsConfig implements PossibleDataRaceBetweenThreadsSharedConfigSig
{
  Query getQuery() { result = UndefinedPackage::possibleDataRaceBetweenThreadsQuery() }

  class ObjectIdentity = CppObjects::ObjectIdentity;

  class SubObject = CppSubObjects::SubObject;
}

import PossibleDataRaceBetweenThreadsShared<PossibleDataRaceBetweenThreadsConfig>
