/**
 * @id cpp/misra/virtual-base-class-cast-to-derived
 * @name RULE-8-2-1: A virtual base class shall only be cast to a derived class by means of dynamic_cast
 * @description Casting from a virtual base class to a derived class using anything other than
 *              dynamic_cast causes undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-1
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.pointertoavirtualbaseclasscasttoapointer.PointerToAVirtualBaseClassCastToAPointer

class VirtualBaseClassCastToDerivedQuery extends PointerToAVirtualBaseClassCastToAPointerSharedQuery
{
  VirtualBaseClassCastToDerivedQuery() {
    this = Conversions2Package::virtualBaseClassCastToDerivedQuery()
  }
}
