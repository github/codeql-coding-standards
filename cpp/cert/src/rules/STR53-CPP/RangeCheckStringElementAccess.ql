/**
 * @id cpp/cert/range-check-string-element-access
 * @name STR53-CPP: Range check std::string element access
 * @description Accesses to elements of a string should be confirmed to be within the appropriate
 *              range to avoid unexpected or undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/str53-cpp
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.containeraccesswithoutrangecheck.ContainerAccessWithoutRangeCheck as ContainerAccessWithoutRangeCheck

class StringIntegerIndexingCall extends ContainerAccessWithoutRangeCheck::IntegerIndexingCall {
  StringIntegerIndexingCall() {
    exists(Type unspecifiedQualifierType |
      unspecifiedQualifierType = getQualifier().getType().getUnspecifiedType()
    |
      unspecifiedQualifierType.(Class).hasQualifiedName("std", "basic_string")
      or
      unspecifiedQualifierType
          .(DerivedType)
          .getBaseType()
          .getUnspecifiedType()
          .(Class)
          .hasQualifiedName("std", "basic_string")
    )
  }
}

from StringIntegerIndexingCall i, string message
where
  not isExcluded(i, OutOfBoundsPackage::rangeCheckStringElementAccessQuery()) and
  ContainerAccessWithoutRangeCheck::problems(i, message)
select i, message
