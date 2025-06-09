/**
 * @id cpp/cert/placement-new-not-properly-aligned-cert
 * @name MEM54-CPP: Placement new shall be used only with properly aligned pointers
 * @description Using placement new with incorrectly aligned pointers creates objects at misaligned
 *              locations which leads to undefined behaviour.
 * @kind path-problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/cert/id/mem54-cpp
 *       security
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.placementnewnotproperlyaligned.PlacementNewNotProperlyAligned

class PlacementNewNotProperlyAlignedCertQuery extends PlacementNewNotProperlyAlignedSharedQuery {
  PlacementNewNotProperlyAlignedCertQuery() {
    this = AllocationsPackage::placementNewNotProperlyAlignedCertQuery()
  }
}
