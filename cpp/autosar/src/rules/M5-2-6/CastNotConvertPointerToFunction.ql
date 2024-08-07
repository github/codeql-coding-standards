/**
 * @id cpp/autosar/cast-not-convert-pointer-to-function
 * @name M5-2-6: A cast shall not convert a pointer to a function to any other pointer type
 * @description A cast shall not convert a pointer to a function to any other pointer type,
 *              including a pointer to function type, to prevent undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-2-6
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.castsbetweenapointertofunctionandanyothertype.CastsBetweenAPointerToFunctionAndAnyOtherType

class CastNotConvertPointerToFunctionQuery extends CastsBetweenAPointerToFunctionAndAnyOtherTypeSharedQuery
{
  CastNotConvertPointerToFunctionQuery() {
    this = PointersPackage::castNotConvertPointerToFunctionQuery()
  }
}
