// GENERATED FILE - DO NOT MODIFY
import codingstandards.cpp.rules.possibledataracebetweenthreadsshared.PossibleDataRaceBetweenThreadsShared
import codingstandards.cpp.lifetimes.CppObjects as CppObjects
import codingstandards.cpp.lifetimes.CppSubObjects as CppSubObjects

module TestFileConfig implements PossibleDataRaceBetweenThreadsSharedConfigSig {
  Query getQuery() { result instanceof TestQuery }

  class ObjectIdentity = CppObjects::ObjectIdentity;

  class SubObject = CppSubObjects::SubObject;
}

import PossibleDataRaceBetweenThreadsShared<TestFileConfig>
