/**
 * @id c/cert/do-not-subtract-pointers-that-do-not-refer-to-the-same-array
 * @name ARR36-C: Do not subtract two pointers that do not refer to the same array
 * @description Subtraction between pointers referring to differing arrays results in undefined
 *              behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/arr36-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.donotsubtractpointersaddressingdifferentarrays.DoNotSubtractPointersAddressingDifferentArrays

class DoNotSubtractPointersThatDoNotReferToTheSameArrayQuery extends DoNotSubtractPointersAddressingDifferentArraysSharedQuery {
  DoNotSubtractPointersThatDoNotReferToTheSameArrayQuery() {
    this = Memory2Package::doNotSubtractPointersThatDoNotReferToTheSameArrayQuery()
  }
}
