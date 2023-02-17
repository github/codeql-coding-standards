/**
 * @id c/misra/memcpy-memmove-memcmp-arg-not-pointers-to-compatible-types
 * @name RULE-21-15: The pointer arguments to the Standard Library functions memcpy, memmove and memcmp shall be pointers
 * @description Passing pointers to incompatible types as arguments to memcpy, memmove and memcmp
 *              indicates programmers' confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-15
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Pointers

class MemCmpMoveCpy extends Function {
  // Couldn't extend BuiltInFunction because it misses `memcmp`
  MemCmpMoveCpy() {
    this.getName().regexpMatch("mem(cmp|cpy|move)") and
    this.getADeclaration().getAFile().(HeaderFile).getBaseName() = "string.h"
  }
}

predicate memfunArgTypes(FunctionCall fc, Type dstType, Type srcType) {
  (
    fc.getArgument(0).getUnspecifiedType() instanceof PointerType and
    fc.getArgument(1).getUnspecifiedType() instanceof PointerType
    or
    fc.getArgument(0).getUnspecifiedType() instanceof ArrayType and
    fc.getArgument(1).getUnspecifiedType() instanceof ArrayType
  ) and
  dstType = fc.getArgument(0).getUnspecifiedType() and
  srcType = fc.getArgument(1).getUnspecifiedType()
}

from FunctionCall fc
where
  not isExcluded(fc,
    StandardLibraryFunctionTypesPackage::memcpyMemmoveMemcmpArgNotPointersToCompatibleTypesQuery()) and
  exists(MemCmpMoveCpy memfun, Type dstType, Type srcType | fc.getTarget() = memfun |
    dstType = fc.getArgument(0).getUnspecifiedType() and
    srcType = fc.getArgument(1).getUnspecifiedType() and
    (
      dstType instanceof PointerType and
      srcType instanceof PointerType
      or
      dstType instanceof ArrayType and
      srcType instanceof ArrayType
    ) and
    dstType = srcType
  )
select fc, fc.getArgument(0).getUnspecifiedType(), fc.getArgument(1).getUnspecifiedType()
