// GENERATED FILE - DO NOT MODIFY
import codingstandards.cpp.rules.donotdeleteanarraythroughapointeroftheincorrecttypeshared.DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeShared

module TestFileConfig implements DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeSharedConfigSig {
  Query getQuery() { result instanceof TestQuery }
}

module Shared = DoNotDeleteAnArrayThroughAPointerOfTheIncorrectTypeShared<TestFileConfig>;

import Shared::PathGraph
import Shared
