/**
 * Provides a library which includes a `problems` predicate for reporting unused parameters.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.deadcode.UnusedParameters

signature module UnusedParameterSharedConfigSig {
  Query getQuery();

  default predicate excludeParameter(Parameter p) { none() }
}

predicate isMaybeUnusedParameter(Parameter parameter) {
  parameter.getAnAttribute().toString() = "maybe_unused"
}

predicate isLambdaParameter(Parameter parameter) {
  exists(LambdaExpression lambda | lambda.getLambdaFunction().getParameter(_) = parameter)
}

module UnusedParameterShared<UnusedParameterSharedConfigSig Config> {
  query predicate problems(UnusedParameter p, string message, Function f, string fName) {
    not isExcluded(p, Config::getQuery()) and
    not isMaybeUnusedParameter(p) and
    not Config::excludeParameter(p) and
    (if isLambdaParameter(p) then fName = "lambda expression" else fName = f.getQualifiedName()) and
    f = p.getFunction() and
    message = "Unused parameter '" + p.getName() + "' for function $@."
  }
}
