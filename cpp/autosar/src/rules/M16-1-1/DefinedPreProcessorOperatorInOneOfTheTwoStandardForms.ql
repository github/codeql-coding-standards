/**
 * @id cpp/autosar/defined-pre-processor-operator-in-one-of-the-two-standard-forms
 * @name M16-1-1: The defined pre-processor operator shall only be used in one of the two standard forms
 * @description Uses of 'defined' pre-processor operator in anything other than standard form is
 *              either constraint violation or undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m16-1-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

//get what comes after each 'defined' used with or without parenth
string matchesDefinedOperator(PreprocessorBranch e) {
  exists(string portion |
    //separators for instances of defined operator use are: || and &&
    //also put everything on one line, and rm all parenth
    portion =
      e.getHead()
          .replaceAll("\\", " ")
          .replaceAll("(", " ")
          .replaceAll(")", " ")
          .splitAt("||")
          .splitAt("&&") and
    //form: defined identifier
    portion.regexpMatch("^.*defined\\s[^(].*") and
    result = portion.regexpCapture("^.*defined\\s+(.+)$", 1).trim()
  )
}

from PreprocessorBranch e, string arg
where
  (
    e instanceof PreprocessorIf or
    e instanceof PreprocessorElif
  ) and
  arg = matchesDefinedOperator(e) and
  not arg.regexpMatch("^\\w*$") and
  not isExcluded(e, MacrosPackage::definedPreProcessorOperatorInOneOfTheTwoStandardFormsQuery())
select e, "Use of defined with non-standard form: " + arg + "."
