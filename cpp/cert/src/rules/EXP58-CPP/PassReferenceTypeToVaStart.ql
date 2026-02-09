/**
 * @id cpp/cert/pass-reference-type-to-va-start
 * @name EXP58-CPP: Pass an object with a reference type to va_start
 * @description Passing an object of an unsupported type as the second argument to va_start() can
 *              result in undefined behavior that might be exploited to cause data integrity
 *              violations.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp58-cpp
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

from VariableAccess va
where
  not isExcluded(va, ExpressionsPackage::passReferenceTypeToVaStartQuery()) and
  va.getType() instanceof ReferenceType and
  exists(BuiltInVarArgsStart va_start | va_start.getLastNamedParameter() = va)
select va, "A reference-type argument is passed to 'va_start'."
