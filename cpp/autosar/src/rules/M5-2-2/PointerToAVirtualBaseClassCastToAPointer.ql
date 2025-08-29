/**
 * @id cpp/autosar/pointer-to-a-virtual-base-class-cast-to-a-pointer
 * @name M5-2-2: A pointer to a virtual base class shall only be cast to a pointer to a derived class using a dynamic_cast
 * @description A pointer to a virtual base class shall only be cast to a pointer to a derived class
 *              by means of dynamic_cast, otherwise the cast has undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m5-2-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.pointertoavirtualbaseclasscasttoapointer.PointerToAVirtualBaseClassCastToAPointer

class PointerToAVirtualBaseClassCastToAPointerQuery extends PointerToAVirtualBaseClassCastToAPointerSharedQuery
{
  PointerToAVirtualBaseClassCastToAPointerQuery() {
    this = PointersPackage::pointerToAVirtualBaseClassCastToAPointerQuery()
  }
}
