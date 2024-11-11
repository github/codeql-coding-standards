/**
 * Provides a library with a `problems` predicate for the following issue:
 * A comparison of a potentially virtual pointer to member function shall only be with
 * nullptr.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class PotentiallyVirtualPointerOnlyComparesToNullptrSharedQuery extends Query { }

Query getQuery() { result instanceof PotentiallyVirtualPointerOnlyComparesToNullptrSharedQuery }

query predicate problems(
  EqualityOperation equalityComparison, string message, MemberFunction virtualFunction,
  string virtualFunction_string, Expr otherOperand, string otherOperand_string
) {
  not isExcluded(equalityComparison, getQuery()) and
  exists(FunctionAccess accessOperand |
    virtualFunction.isVirtual() and
    equalityComparison.getAnOperand() = accessOperand and
    accessOperand.getTarget() = virtualFunction and
    otherOperand = equalityComparison.getAnOperand() and
    not otherOperand = accessOperand and
    not otherOperand.getType() instanceof NullPointerType and
    message =
      "A pointer to member virtual function $@ is tested for equality with non-null-pointer-constant $@." and
    virtualFunction_string = virtualFunction.getName() and
    otherOperand_string = otherOperand.toString()
  )
}
