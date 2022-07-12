/**
 * @id c/cert/rand-used-for-generating-pseudorandom-numbers
 * @name MSC30-C: Do not use the rand() function for generating pseudorandom numbers
 * @description rand() shall not be used to generate pseudorandom numbers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc30-c
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.donotuserandforgeneratingpseudorandomnumbers.DoNotUseRandForGeneratingPseudorandomNumbers

class RandUsedForGeneratingPseudorandomNumbersQuery extends DoNotUseRandForGeneratingPseudorandomNumbersSharedQuery {
  RandUsedForGeneratingPseudorandomNumbersQuery() {
    this = MiscPackage::randUsedForGeneratingPseudorandomNumbersQuery()
  }
}
