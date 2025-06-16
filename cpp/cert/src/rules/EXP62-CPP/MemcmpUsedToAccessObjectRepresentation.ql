/**
 * @id cpp/cert/memcmp-used-to-access-object-representation
 * @name EXP62-CPP: Do not use memcmp to access bits that are not part of the object's value
 * @description Do not use memcmp to access the bits of an object representation that are not part
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
import codingstandards.cpp.rules.memcmpusedtocomparepaddingdata.MemcmpUsedToComparePaddingData

class MemcmpUsedToAccessObjectRepresentationQuery extends MemcmpUsedToComparePaddingDataSharedQuery {
  MemcmpUsedToAccessObjectRepresentationQuery() {
    this = RepresentationPackage::memcmpUsedToAccessObjectRepresentationQuery()
  }
}
