/**
 * @id cpp/misra/out-of-range-enum-cast-critical-unspecified-behavior
 * @name RULE-4-1-3: Out-of-range enumeration cast leads to critical unspecified behavior
 * @description Casting to an enumeration value outside the range of the enumeration's values
 *              results in critical unspecified behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-4-1-3
 *       correctness
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.donotcasttoanoutofrangeenumerationvalueshared.DoNotCastToAnOutOfRangeEnumerationValueShared

module OutOfRangeEnumCastCriticalUnspecifiedBehaviorConfig implements
  DoNotCastToAnOutOfRangeEnumerationValueSharedConfigSig
{
  Query getQuery() {
    result = UndefinedPackage::outOfRangeEnumCastCriticalUnspecifiedBehaviorQuery()
  }
}

import DoNotCastToAnOutOfRangeEnumerationValueShared<OutOfRangeEnumCastCriticalUnspecifiedBehaviorConfig>
