/**
 * @id c/misra/string-function-pointer-argument-out-of-bounds
 * @name RULE-21-17: Use of the string handling functions from <string.h> shall not result in accesses beyond the bounds
 * @description Use of string manipulation functions from <string.h> with improper buffer sizes can
 *              result in out-of-bounds buffer accesses.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-21-17
 *       correctness
 *       security
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.OutOfBounds

class RULE_21_17_Subset_FC = OOB::SimpleStringLibraryFunctionCall;

from
  RULE_21_17_Subset_FC fc, string message, Expr bufferArg, string bufferArgStr,
  Expr sizeOrOtherBufferArg, string otherStr
where
  not isExcluded(fc, OutOfBoundsPackage::stringFunctionPointerArgumentOutOfBoundsQuery()) and
  OOB::problems(fc, message, bufferArg, bufferArgStr, sizeOrOtherBufferArg, otherStr)
select fc, message, bufferArg, bufferArgStr, sizeOrOtherBufferArg, otherStr