/**
 * @id cpp/autosar/c-style-arrays-used
 * @name A18-1-1: C-style arrays shall not be used
 * @description Do not use C-style arrays.  Prefer std::array.  C-style arrays that are static
 *              constexpr data members are allowed.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-1-1
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/** A static constexpr data member of a C-style array type */
class StaticConstExprArrayDataMember extends MemberVariable {
  StaticConstExprArrayDataMember() {
    // Add `isStatic` for completeness, because you cannot declare a non-static constexpr datamember
    this.isStatic() and
    this.isConstexpr() and
    this.getType().getUnspecifiedType() instanceof ArrayType
  }
}

from Variable v
where
  not isExcluded(v, BannedSyntaxPackage::cStyleArraysUsedQuery()) and
  exists(ArrayType a | v.getType() = a | not v instanceof StaticConstExprArrayDataMember) and
  // Exclude the compiler generated __func__ as it is the only way to access the function name information
  not v.getName() = "__func__"
select v, "Variable " + v.getName() + " declares a c-style array."
