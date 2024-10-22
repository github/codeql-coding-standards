/**
 * @id c/cert/unsigned-integer-operations-wrap-around
 * @name INT30-C: Ensure that unsigned integer operations do not wrap
 * @description Unsigned integer expressions do not strictly overflow, but instead wrap around in a
 *              modular way. If the size of the type is not sufficient, this can happen
 *              unexpectedly.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/int30-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.unsignedoperationwithconstantoperandswraps.UnsignedOperationWithConstantOperandsWraps

class UnsignedIntegerOperationsWrapAroundQuery extends UnsignedOperationWithConstantOperandsWrapsSharedQuery
{
  UnsignedIntegerOperationsWrapAroundQuery() {
    this = IntegerOverflowPackage::unsignedIntegerOperationsWrapAroundQuery()
  }
}
