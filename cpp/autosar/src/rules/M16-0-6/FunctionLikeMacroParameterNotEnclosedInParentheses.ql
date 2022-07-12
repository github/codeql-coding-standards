/**
 * @id cpp/autosar/function-like-macro-parameter-not-enclosed-in-parentheses
 * @name M16-0-6: In the definition of a function-like macro, each instance of a parameter shall be enclosed in parentheses
 * @description In the definition of a function-like macro, each instance of a parameter shall be
 *              enclosed in parentheses, otherwise the result of preprocessor macro substitition may
 *              not be as expected.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-6
 *       correctness
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.FunctionLikeMacro

from FunctionLikeMacro m, string param, string squishedBody
where
  not isExcluded(m, MacrosPackage::functionLikeMacroParameterNotEnclosedInParenthesesQuery()) and
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
  )
select m,
  "Accesses of parameter '" + param + "' are not always enclosed in parentheses in the macro " +
    m.getName() + "."
