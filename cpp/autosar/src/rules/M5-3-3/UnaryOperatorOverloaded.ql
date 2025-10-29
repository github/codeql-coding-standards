/**
 * @id cpp/autosar/unary-operator-overloaded
 * @name M5-3-3: The unary & operator shall not be overloaded
 * @description The unary & operator shall not be overloaded.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-3-3
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 *       coding-standards/baseline/safety
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.addressofoperatoroverloaded.AddressOfOperatorOverloaded

class UnaryOperatorOverloadedQuery extends AddressOfOperatorOverloadedSharedQuery {
  UnaryOperatorOverloadedQuery() { this = OperatorsPackage::unaryOperatorOverloadedQuery() }
}
