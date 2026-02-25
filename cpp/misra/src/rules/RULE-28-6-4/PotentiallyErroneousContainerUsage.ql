/**
 * @id cpp/misra/potentially-erroneous-container-usage
 * @name RULE-28-6-4: The result of std::remove, std::remove_if, std::unique and empty shall be used
 * @description The `empty` method may be confused with `clear`, and the family of algorithms
 *              similar to `std::remove` require the resulting iterator to be used in order to
 *              properly handle the modifications performed.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-28-6-4
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Iterators

predicate isRemoveOrUniqueCall(FunctionCall fc) {
  fc.getTarget().hasQualifiedName("std", ["remove", "remove_if", "unique"]) and
  fc.getAnArgument().getUnderlyingType() instanceof IteratorType
}

predicate isEmptyCall(FunctionCall fc) {
  fc.getTarget().getName() = "empty" and
  (
    fc.getTarget().hasQualifiedName("std", "empty") or
    fc.getTarget().(MemberFunction).getDeclaringType().hasQualifiedName("std", _)
  )
}

from FunctionCall fc, string message
where
  not isExcluded(fc, DeadCode11Package::potentiallyErroneousContainerUsageQuery()) and
  fc = any(ExprStmt es).getExpr() and
  (isRemoveOrUniqueCall(fc) or isEmptyCall(fc)) and
  message = "Result of call to '" + fc.getTarget().getName() + "' is not used."
select fc, message
