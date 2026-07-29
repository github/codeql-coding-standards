/**
 * @id c/misra/possible-data-race-between-threads
 * @name DIR-5-1: There shall be no data races between threads
 * @description Threads shall not access the same memory location concurrently without utilization
 *              of thread synchronization objects.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/misra/id/dir-5-1
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Objects as CObjects
import codingstandards.c.SubObjects as CSubObjects
import codingstandards.cpp.rules.possibledataracebetweenthreadsshared.PossibleDataRaceBetweenThreadsShared

module PossibleDataRaceBetweenThreadsConfig implements PossibleDataRaceBetweenThreadsSharedConfigSig
{
  Query getQuery() { result = Concurrency9Package::possibleDataRaceBetweenThreadsQuery() }

  class ObjectIdentity = CObjects::ObjectIdentity;

  class SubObject = CSubObjects::SubObject;
}

import PossibleDataRaceBetweenThreadsShared<PossibleDataRaceBetweenThreadsConfig>
