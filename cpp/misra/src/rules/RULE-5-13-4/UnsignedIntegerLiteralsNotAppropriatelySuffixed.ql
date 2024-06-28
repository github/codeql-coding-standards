/**
 * @id cpp/misra/unsigned-integer-literals-not-appropriately-suffixed
 * @name RULE-5-13-4: Unsigned integer literals shall be appropriately suffixed
 * @description Unsigned integer literals shall be appropriately suffixed.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-5-13-4
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.unsignedintegerliteralsnotappropriatelysuffixed_shared.UnsignedIntegerLiteralsNotAppropriatelySuffixed_shared

class UnsignedIntegerLiteralsNotAppropriatelySuffixedQuery extends UnsignedIntegerLiteralsNotAppropriatelySuffixed_sharedSharedQuery
{
  UnsignedIntegerLiteralsNotAppropriatelySuffixedQuery() {
    this = ImportMisra23Package::unsignedIntegerLiteralsNotAppropriatelySuffixedQuery()
  }
}
