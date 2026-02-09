/**
 * @id cpp/cert/pass-promotable-primitive-type-to-va-start
 * @name EXP58-CPP: Pass a primitive type that will be promoted to va_start
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

predicate isDefaultArgPromotable(Expr e) {
  e.getType() instanceof FloatType or
  e.getUnderlyingType().(IntegralType).getSize() < any(IntType i).getSize()
}

from VariableAccess va
where
  not isExcluded(va, ExpressionsPackage::passPromotablePrimitiveTypeToVaStartQuery()) and
  isDefaultArgPromotable(va) and
  exists(BuiltInVarArgsStart va_start | va_start.getLastNamedParameter() = va)
select va, "Argument to 'va_start' will undergo default-argument promotion."
