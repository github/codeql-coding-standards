/**
 * @id c/cert/memcmp-used-to-compare-floats
 * @name FLP37-C: Do not use object representations to compare floating-point values
 * @description
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/flp37-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.security.BufferAccess

/**
 * A type which contains, directly or indirectly, a floating-point type.
 */
class FloatContainingType extends Type {
  FloatContainingType() {
    this instanceof FloatingPointType
    or
    this.(Class).getAField().getType().getUnspecifiedType() instanceof FloatContainingType
  }
}

from MemcmpBA cmp, string buffDesc, Expr arg, FloatContainingType type
where
  not isExcluded(cmp, FloatingTypesPackage::memcmpUsedToCompareFloatsQuery()) and
  arg = cmp.getBuffer(buffDesc, _) and
  arg.getUnconverted().getUnspecifiedType().(PointerType).getBaseType() = type
select cmp,
  "memcmp is used to compare a floating-point value in the $@ which is of type " + type + ".", arg,
  buffDesc
