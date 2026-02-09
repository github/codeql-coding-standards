/**
 * @id cpp/cert/using-default-operator-new-for-over-aligned-types
 * @name MEM57-CPP: Avoid using default operator new for over-aligned types
 * @description Operator new only guarantees that it will return a pointer with fundamental
 *              alignment, which can lead to undefined behavior with over-aligned types.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/mem57-cpp
 *       correctness
 *       security
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Alignment
import codingstandards.cpp.Allocations

from NewOrNewArrayExpr newExpr, Type overAlignedType
where
  not isExcluded(newExpr, AllocationsPackage::usingDefaultOperatorNewForOverAlignedTypesQuery()) and
  not exists(newExpr.getPlacementPointer()) and
  overAlignedType = newExpr.getAllocatedType() and
  // Alignment of type is greater than global defined max_align_t
  overAlignedType.getAlignment() > getGlobalMaxAlignT()
select newExpr,
  "Use of default operator new for over-aligned type $@ (alignment: " +
    newExpr.getAllocatedType().getAlignment() + ", max_align_t: " + getGlobalMaxAlignT() + ").",
  overAlignedType, overAlignedType.getName()
