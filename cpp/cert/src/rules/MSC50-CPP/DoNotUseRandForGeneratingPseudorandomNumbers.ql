/**
 * @id cpp/cert/do-not-use-rand-for-generating-pseudorandom-numbers
 * @name MSC50-CPP: Do not use std::rand() for generating pseudorandom numbers
 * @description std::rand shall not be used to generate pseudorandom numbers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc50-cpp
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

predicate isRand(FunctionCall fc) { fc.getTarget().hasGlobalOrStdName("rand") }

from FunctionCall fc
where
  not isExcluded(fc, BannedFunctionsPackage::doNotUseRandForGeneratingPseudorandomNumbersQuery()) and
  isRand(fc)
select fc, "Use of banned function " + fc.getTarget().getQualifiedName() + "."
