/**
 * @id cpp/autosar/placement-new-insufficient-storage-autosar
 * @name A18-5-10: Placement new shall be used only with pointers to sufficient storage capacity
 * @description Using placement new with pointers without sufficient storage capacity creates
 *              objects which can overflow the bounds of the allocated memory leading to undefined
 *              behaviour.
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
import codingstandards.cpp.rules.placementnewinsufficientstorage.PlacementNewInsufficientStorage

class PlacementNewInsufficientStorageAutosarQuery extends PlacementNewInsufficientStorageSharedQuery {
  PlacementNewInsufficientStorageAutosarQuery() {
    this = AllocationsPackage::placementNewInsufficientStorageAutosarQuery()
  }
}
