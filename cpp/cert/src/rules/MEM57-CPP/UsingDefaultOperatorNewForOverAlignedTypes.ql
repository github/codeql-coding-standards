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
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

/*
 * In theory each compilation of each file can have a different `max_align_t` value (for example,
 * if the same file is compiled under different compilers in the same database). We don't have the
 * fine-grained data to determine which compilation each operator new call is from, so we instead
 * report only in cases where there's a single clear alignment for the whole database.
 */

class MaxAlignT extends TypedefType {
  MaxAlignT() { getName() = "max_align_t" }
}

/**
 * Gets the alignment for `max_align_t`, assuming there is a single consistent alignment for the
 * database.
 */
int getGlobalMaxAlignT() {
  count(MaxAlignT m | | m.getAlignment()) = 1 and
  result = any(MaxAlignT t).getAlignment()
}

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
