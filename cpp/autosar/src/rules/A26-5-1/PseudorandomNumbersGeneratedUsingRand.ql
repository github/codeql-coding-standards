/**
 * @id cpp/autosar/pseudorandom-numbers-generated-using-rand
 * @name A26-5-1: Pseudorandom numbers shall not be generated using std::rand()
 * @description std::rand shall not be used to generate pseudorandom numbers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a26-5-1
 *       security
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.donotuserandforgeneratingpseudorandomnumbers.DoNotUseRandForGeneratingPseudorandomNumbers

class PseudorandomNumbersGeneratedUsingRandQuery extends DoNotUseRandForGeneratingPseudorandomNumbersSharedQuery {
  PseudorandomNumbersGeneratedUsingRandQuery() {
    this = BannedFunctionsPackage::pseudorandomNumbersGeneratedUsingRandQuery()
  }
}
