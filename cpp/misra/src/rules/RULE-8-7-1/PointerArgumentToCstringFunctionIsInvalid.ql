/**
 * @id cpp/misra/pointer-argument-to-cstring-function-is-invalid
 * @name RULE-8-7-1: Pointer and index arguments passed to functions in <cstring> shall not be invalid.
 * @description Pointer and index arguments passed to functions in <cstring> should result in valid
 *              reads and/or writes.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-8-7-1
 *       scope/system
 *       external/misra/enforcement/undecidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.OutOfBounds

from
  OOB::BufferAccessLibraryFunctionCall fc, string message, Expr bufferArg, string bufferArgStr,
  Expr sizeOrOtherBufferArg, string otherStr
where
  not isExcluded(fc, OutOfBoundsPackage::libraryFunctionArgumentOutOfBoundsQuery()) and
  OOB::problems(fc, message, bufferArg, bufferArgStr, sizeOrOtherBufferArg, otherStr)
select fc, message, bufferArg, bufferArgStr, sizeOrOtherBufferArg, otherStr

