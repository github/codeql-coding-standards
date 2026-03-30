/**
 * @id cpp/cert/do-not-cast-to-an-out-of-range-enumeration-value
 * @name INT50-CPP: Do not cast to an out-of-range enumeration value
 * @description Casting to an out-of-range enumeration value leads to unspecified or undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/int50-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.donotcasttoanoutofrangeenumerationvalueshared.DoNotCastToAnOutOfRangeEnumerationValueShared

module DoNotCastToAnOutOfRangeEnumerationValueConfig implements
  DoNotCastToAnOutOfRangeEnumerationValueSharedConfigSig
{
  Query getQuery() { result = TypeRangesPackage::doNotCastToAnOutOfRangeEnumerationValueQuery() }
}

import DoNotCastToAnOutOfRangeEnumerationValueShared<DoNotCastToAnOutOfRangeEnumerationValueConfig>
