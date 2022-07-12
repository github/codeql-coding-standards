/**
 * @id cpp/autosar/placement-new-not-properly-aligned-autosar
 * @name A18-5-10: Placement new shall be used only with properly aligned pointers
 * @description Using placement new with incorrectly aligned pointers creates objects at misaligned
 *              locations which leads to undefined behaviour.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a18-5-10
 *       security
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.placementnewnotproperlyaligned.PlacementNewNotProperlyAligned

class PlacementNewNotProperlyAlignedAutosarQuery extends PlacementNewNotProperlyAlignedSharedQuery {
  PlacementNewNotProperlyAlignedAutosarQuery() {
    this = AllocationsPackage::placementNewNotProperlyAlignedAutosarQuery()
  }
}
