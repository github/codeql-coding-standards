/**
 * Provides a library which includes a `problems` predicate for reporting unused parameters.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.deadcode.UnusedParameters

abstract class UnusedParameterSharedQuery extends Query { }

Query getQuery() { result instanceof UnusedParameterSharedQuery }

query predicate isMaybeUnusedParameter(Parameter parameter) {
  parameter.getAnAttribute().toString() = "maybe_unused"
}

predicate isLambdaParameter(Parameter parameter) {
  exists(LambdaExpression lambda | lambda.getLambdaFunction().getParameter(_) = parameter)
}

predicate isLambdaMaybeUnusedParameter(Parameter parameter) {
  exists(LambdaExpression lambda | lambda.getLambdaFunction().getParameter(_) = parameter) and
  isMaybeUnusedParameter(parameter)
}

query predicate lambdaExprParamHasAccess(Parameter parameter) {
  exists(VariableAccess va | isLambdaParameter(parameter) and parameter.getAnAccess() = va)
}

query predicate problems(UnusedParameter p, string message, Function f, string fName) {
  not isExcluded(p, getQuery()) and
  (
    not isMaybeUnusedParameter(p) and
    f = p.getFunction() and
    // Virtual functions are covered by a different rule
    not f.isVirtual()
  ) and
  message = "Unused parameter '" + p.getName() + "' for function $@." and
  // fName = f.getQualifiedName()
  fName = "TODO."
}
