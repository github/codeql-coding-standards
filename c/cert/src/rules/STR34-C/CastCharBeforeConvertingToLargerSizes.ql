/**
 * @id c/cert/cast-char-before-converting-to-larger-sizes
 * @name STR34-C: Cast characters to unsigned char before converting to larger integer sizes
 * @description Not casting smaller char sizes to unsigned char before converting to lager integer
 *              sizes may lead to unpredictable program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/str34-c
 *       correctness
 *       security
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p8
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.castcharbeforeconvertingtolargersizes.CastCharBeforeConvertingToLargerSizes

class CastCharBeforeConvertingToLargerSizesQuery extends CastCharBeforeConvertingToLargerSizesSharedQuery
{
  CastCharBeforeConvertingToLargerSizesQuery() {
    this = Strings3Package::castCharBeforeConvertingToLargerSizesQuery()
  }
}
