/**
 * Provides a library with a `problems` predicate for the following issue:
 * In the definition of a function-like macro, each instance of a parameter
 * shall be enclosed in parentheses, otherwise the result of preprocessor macro
 * substitition may not be as expected.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.FunctionLikeMacro

abstract class MacroParameterNotEnclosedInParenthesesSharedQuery extends Query { }

Query getQuery() { result instanceof MacroParameterNotEnclosedInParenthesesSharedQuery }

query predicate problems(FunctionLikeMacro m, string message) {
  exists(string param, string squishedBody |
    not isExcluded(m, getQuery()) and
    param = m.getAParameter() and
    //chop out identifiers that contain a substring matching our parameter identifier (i.e., wrapped in other valid identifier characters)
    squishedBody =
      m.getBody()
          .regexpReplaceAll("([\\w]*" + param + "[\\w]+)|([\\w]+" + param + "[\\w]*)", "")
          .replaceAll(" ", "") and
    (
      squishedBody.regexpMatch(".*[^\\(]" + param + ".*") or
      squishedBody.regexpMatch(".*" + param + "[^\\)].*") or
      squishedBody.regexpMatch("^" + param + "$")
    ) and
    not (
      //case where param is right hand side operand to either # or ## operator
      squishedBody.regexpMatch(".*\\#{1,2}?" + param + ".*")
      or
      //case where param is left hand side operand to either # or ## operator
      squishedBody.regexpMatch(".*" + param + "\\#{1,2}?.*")
    ) and
    message =
      "Accesses of parameter '" + param + "' are not always enclosed in parentheses in the macro " +
        m.getName() + "."
  )
}
