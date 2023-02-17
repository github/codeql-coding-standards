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

class MemCmpMoveCpy extends BuiltInFunction {
  MemCmpMoveCpy() { this.getName().regexpMatch(".+mem(cmp|cpy|move).+") }
}

from FunctionCall fc
where
  not isExcluded(fc,
    StandardLibraryFunctionTypesPackage::memcpyMemmoveMemcmpArgNotPointersToCompatibleTypesQuery()) and
  exists(MemCmpMoveCpy memfun | fc.getTarget() = memfun |
    fc.getArgument(0).getUnspecifiedType() = fc.getArgument(1).getUnspecifiedType()
  )
select fc, fc.getArgument(0).getUnspecifiedType(), fc.getArgument(1).getUnspecifiedType()
