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
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.commons.CommonType

from Cast c
where
  not isExcluded(c, Strings3Package::castCharBeforeConvertingToLargerSizesQuery()) and
  // find cases where there is a conversion happening wherein the
  // base type is a char
  c.getExpr().getType() instanceof CharType and
  not c.getExpr().getType() instanceof UnsignedCharType and
  // it's a bigger type
  c.getType().getSize() > c.getExpr().getType().getSize() and
  // and it's some kind of integer type
  c.getType() instanceof IntegralType
select c.getExpr(),
  "Expression not converted to `unsigned char` before converting to a larger integer type."
