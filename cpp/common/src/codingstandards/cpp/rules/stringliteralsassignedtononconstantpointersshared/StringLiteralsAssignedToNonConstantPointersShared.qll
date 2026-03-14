/**
 * Provides a configurable module StringLiteralsAssignedToNonConstantPointersShared with a `problems` predicate
 * for the following issue:
 * The type of string literal as of C++0x was changed from 'array of char' to array of
 * const char and therefore assignment to a non-const pointer is considered an error,
 * which is reported as a warning by some compliers.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

signature module StringLiteralsAssignedToNonConstantPointersSharedConfigSig {
  Query getQuery();
}

module StringLiteralsAssignedToNonConstantPointersShared<
  StringLiteralsAssignedToNonConstantPointersSharedConfigSig Config>
{
  query predicate problems(ArrayToPointerConversion apc, string message) {
    not isExcluded(apc, Config::getQuery()) and
    apc.getExpr() instanceof StringLiteral and
    apc.getExpr().getUnderlyingType().(ArrayType).getBaseType().isConst() and
    not apc.getFullyConverted().getType().getUnderlyingType().(PointerType).getBaseType().isConst() and
    message = "String literal assigned to non-const pointer."
  }
}
