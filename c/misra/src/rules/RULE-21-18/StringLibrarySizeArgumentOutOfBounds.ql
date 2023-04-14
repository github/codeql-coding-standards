/**
 * @id c/misra/string-library-size-argument-out-of-bounds
 * @name RULE-21-18: The size_t argument passed to any function in <string.h> shall have an appropriate value
 * @description Passing a size_t argument that is non-positive or greater than the size of the
 *              smallest buffer argument to any function in <string.h> may result in out-of-bounds
 *              buffer accesses.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-21-18
 *       correctness
 *       security
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.OutOfBounds

class RULE_21_18_Subset_FC extends OOB::BufferAccessLibraryFunctionCall {
  RULE_21_18_Subset_FC() {
    this.getTarget().getName() =
      OOB::getNameOrInternalName([
          "mem" + ["chr", "cmp", "cpy", "move", "set"], "str" + ["ncat", "ncmp", "ncpy", "xfrm"]
        ])
  }
}

from
  RULE_21_18_Subset_FC fc, string message, Expr bufferArg, string bufferArgStr,
  Expr sizeOrOtherBufferArg, string otherStr
where
  not isExcluded(fc, OutOfBoundsPackage::stringLibrarySizeArgumentOutOfBoundsQuery()) and
  OOB::problems(fc, message, bufferArg, bufferArgStr, sizeOrOtherBufferArg, otherStr)
select fc, message, bufferArg, bufferArgStr, sizeOrOtherBufferArg, otherStr
