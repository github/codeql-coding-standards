/**
 * @id c/cert/library-function-argument-out-of-bounds
 * @name ARR38-C: Guarantee that library functions do not form invalid pointers
 * @description Passing out-of-bounds pointers or erroneous size arguments to standard library
 *              functions can result in out-of-bounds accesses and other undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/arr38-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
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