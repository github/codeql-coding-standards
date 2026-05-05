// GENERATED FILE - DO NOT MODIFY
import codingstandards.cpp.rules.possibledataracebetweenthreadsshared.PossibleDataRaceBetweenThreadsShared
import codingstandards.c.Objects as CObjects
import codingstandards.c.SubObjects as CSubObjects

module TestFileConfig implements PossibleDataRaceBetweenThreadsSharedConfigSig {
  Query getQuery() { result instanceof TestQuery }

  class ObjectIdentity = CObjects::ObjectIdentity;

  class SubObject = CSubObjects::SubObject;
}

import PossibleDataRaceBetweenThreadsShared<TestFileConfig>
