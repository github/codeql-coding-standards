/**
 * @id cpp/autosar/applied-to-objects-of-pointer-type
 * @name M5-0-18: >, >=, <, <= shall not be applied to pointers pointing to different arrays
 * @description >, >=, <, <= applied to objects of pointer type produces undefined behavior, except
 *              where they point to the same array.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/m5-0-18
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.donotuserelationaloperatorswithdifferingarrays.DoNotUseRelationalOperatorsWithDifferingArrays

class AppliedToObjectsOfPointerTypeQuery extends DoNotUseRelationalOperatorsWithDifferingArraysSharedQuery {
  AppliedToObjectsOfPointerTypeQuery() {
    this = PointersPackage::appliedToObjectsOfPointerTypeQuery()
  }
}
