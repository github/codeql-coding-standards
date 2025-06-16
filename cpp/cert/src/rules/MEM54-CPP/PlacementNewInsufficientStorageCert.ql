/**
 * @id cpp/cert/placement-new-insufficient-storage-cert
 * @name MEM54-CPP: Placement new shall be used only with pointers to sufficient storage capacity
 * @description Using placement new with pointers without sufficient storage capacity creates
 *              objects which can overflow the bounds of the allocated memory leading to undefined
 *              behaviour.
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
import codingstandards.cpp.rules.placementnewinsufficientstorage.PlacementNewInsufficientStorage

class PlacementNewInsufficientStorageCertQuery extends PlacementNewInsufficientStorageSharedQuery {
  PlacementNewInsufficientStorageCertQuery() {
    this = AllocationsPackage::placementNewInsufficientStorageCertQuery()
  }
}
