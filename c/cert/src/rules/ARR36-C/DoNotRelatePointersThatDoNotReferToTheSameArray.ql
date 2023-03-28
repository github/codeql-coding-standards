/**
 * @id c/cert/do-not-relate-pointers-that-do-not-refer-to-the-same-array
 * @name ARR36-C: Do not subtract two pointers that do not refer to the same array
 * @description Comparison using the >, >=, <, and <= operators between pointers referring to
 *              differing arrays results in undefined behavior.
 * @kind path-problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/arr36-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.donotuserelationaloperatorswithdifferingarrays.DoNotUseRelationalOperatorsWithDifferingArrays

class DoNotRelatePointersThatDoNotReferToTheSameArrayQuery extends DoNotUseRelationalOperatorsWithDifferingArraysSharedQuery {
  DoNotRelatePointersThatDoNotReferToTheSameArrayQuery() {
    this = Memory2Package::doNotRelatePointersThatDoNotReferToTheSameArrayQuery()
  }
}
