/**
 * @id cpp/cert/memcpy-used-to-access-object-representation
 * @name EXP62-CPP: Do not use memcpy to access bits that are not part of the object's value
 * @description Do not use memcpy to access the bits of an object representation that are not part
 *              of the object's value representation.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp62-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import semmle.code.cpp.padding.Padding
import semmle.code.cpp.security.BufferAccess
import VirtualTable

from MemcpyBA cpy, Class cl1
where
  not isExcluded(cpy, RepresentationPackage::memcpyUsedToAccessObjectRepresentationQuery()) and
  hasVirtualtable(cl1) and
  cpy.getBuffer(_, _).(VariableAccess).getTarget().getUnspecifiedType().(PointerType).getBaseType() =
    cl1 //pointer type cast to pointer type
select cpy, cpy + " accesses bits which are not part of the object's value representation."
