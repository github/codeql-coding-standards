/**
 * @id cpp/cert/do-not-use-rand-for-generating-pseudorandom-numbers
 * @name MSC50-CPP: Do not use std::rand() for generating pseudorandom numbers
 * @description std::rand shall not be used to generate pseudorandom numbers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc50-cpp
 *       security
 *       scope/single-translation-unit
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.donotuserandforgeneratingpseudorandomnumbers.DoNotUseRandForGeneratingPseudorandomNumbers

class DoNotUseRandForGeneratingPseudorandomNumbersQuery extends DoNotUseRandForGeneratingPseudorandomNumbersSharedQuery
{
  DoNotUseRandForGeneratingPseudorandomNumbersQuery() {
    this = BannedFunctionsPackage::doNotUseRandForGeneratingPseudorandomNumbersQuery()
  }
}
