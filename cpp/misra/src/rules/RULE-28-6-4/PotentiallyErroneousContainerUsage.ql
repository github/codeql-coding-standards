import cpp
import codingstandards.cpp.misra

predicate isRemoveOrUniqueCall(FunctionCall fc) {
  exists(string name | name = fc.getTarget().getName() |
    name = "remove" or
    name = "remove_if" or
    name = "unique"
  ) and
  fc.getTarget().hasQualifiedName("std", _)
}

predicate isEmptyCall(FunctionCall fc) {
  fc.getTarget().getName() = "empty" and
  (
    fc.getTarget().hasQualifiedName("std", "empty") or
    fc.getTarget() instanceof MemberFunction
  )
}

from FunctionCall fc, string message
where
  not isExcluded(fc, DeadCode11Package::potentiallyErroneousContainerUsageQuery()) and
  exists(ExprStmt es | es.getExpr() = fc) and
  (
    isRemoveOrUniqueCall(fc) and
    message = "Result of call to '" + fc.getTarget().getName() + "' is not used."
    or
    isEmptyCall(fc) and
    message = "Result of call to 'empty' is not used."
  )
select fc, message
