/**
 * @id c/misra/controlling-expression-if-directive
 * @name RULE-20-8: The controlling expression of a #if or #elif preprocessing directive shall evaluate to 0 or 1
 * @description A controlling expression of a #if or #elif preprocessing directive that does not
 *              evaluate to 0 or 1 makes code more difficult to understand.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-8
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

/*  A controlling expression is evaluated if it is not excluded (guarded by another controlling expression that is not taken). This translates to it either being taken or not taken.  */
predicate isEvaluated(PreprocessorBranch b) { b.wasTaken() or b.wasNotTaken() }

class IfOrElifPreprocessorBranch extends PreprocessorBranch {
  IfOrElifPreprocessorBranch() {
    this instanceof PreprocessorIf or this instanceof PreprocessorElif
  }
}

/**
 * Looks like it contains a single macro, which may be undefined
 */
class SimpleMacroPreprocessorBranch extends IfOrElifPreprocessorBranch {
  SimpleMacroPreprocessorBranch() { this.getHead().regexpMatch("[a-zA-Z_][a-zA-Z0-9_]+") }
}

class SimpleNumericPreprocessorBranch extends IfOrElifPreprocessorBranch {
  SimpleNumericPreprocessorBranch() { this.getHead().regexpMatch("[0-9]+") }
}

class ZeroOrOnePreprocessorBranch extends SimpleNumericPreprocessorBranch {
  ZeroOrOnePreprocessorBranch() { this.getHead().regexpMatch("[0|1]") }
}

predicate containsOnlySafeOperators(IfOrElifPreprocessorBranch b) {
  containsOnlyDefinedOperator(b)
  or
  //logic: comparison operators eval last, so they make it safe?
  b.getHead().regexpMatch(".*[\\&\\&|\\|\\||>|<|==].*")
}

//all defined operators is definitely safe
predicate containsOnlyDefinedOperator(IfOrElifPreprocessorBranch b) {
  forall(string portion |
    portion =
      b.getHead()
          .replaceAll("\\", " ")
          .replaceAll("(", " ")
          .replaceAll(")", " ")
          .splitAt("||")
          .splitAt("&&")
  |
    portion.regexpMatch("^.*defined\\s[^(].*")
  )
}

class BinaryValuedMacro extends Macro {
  BinaryValuedMacro() { this.getBody().regexpMatch("\\(?(0|1)\\)?") }
}

from IfOrElifPreprocessorBranch b, string msg
where
  not isExcluded(b, Preprocessor3Package::controllingExpressionIfDirectiveQuery()) and
  isEvaluated(b) and
  //a catch all for anything that is not only comprised of defined operators
  //after which the expression is guaranteed to eval to 0 or 1
  not containsOnlySafeOperators(b) and
  //any single number, that is not 0|1
  (
    b instanceof SimpleNumericPreprocessorBranch and
    not b instanceof ZeroOrOnePreprocessorBranch and
    msg = " a simple number " + b.getHead()
  )
  or
  //contains exactly one instance of a macro name that is not representing 0|1
  b instanceof SimpleMacroPreprocessorBranch and
  exists(Macro m |
    m.getName() = b.getHead() and
    not m instanceof BinaryValuedMacro and
    not m.getBody().regexpMatch(".*[\\&\\&|\\|\\||>|<|==].*") and
    msg = " a macro value " + m.getBody()
  )
  or
  //something that looks like an expression with arithmetic operators and numeric operands
  //assume unless it it enclosed in not operator it does not evaluate to 0 or 1
  b.getHead().regexpMatch(".*!*[0-9]+\\s*[+|-|\\\\*|%|\\/]+\\s*!*[0-9]+.*") and
  not b.getHead().regexpMatch("^!\\(.*") and
  msg = " an arithmetic expression."
select b, "Directive expression " + b.getHead() + " evaluates to" + msg
