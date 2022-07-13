/**
 * @id cpp/autosar/unused-loop-counter-for-container-iteration
 * @name A6-5-1: Unused loop counter when iterating over a container
 * @description A for-loop that loops through all elements of the container and does not use its
 *              loop-counter shall not be used.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/a6-5-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class TotalArrayForStmt extends ForStmt {
  TotalArrayForStmt() {
    exists(LocalVariable array |
      array.getFunction() = this.getEnclosingFunction() and
      array.getType().(ArrayType).getArraySize() =
        this.getCondition().(LTExpr).getRightOperand().getValue().toInt()
    )
    or
    exists(FunctionCall begin, FunctionCall end |
      /*
       *  The loop's initialization must contain a function call to std::begin():
       *
       *      for (... = std::begin(...); ...; ...)
       */

      this.getInitialization() = begin.getEnclosingStmt+() and
      begin.getTarget().hasQualifiedName("std", "begin") and
      /*
       * And the loop's condition must be a != comparison to std::end():
       *
       *     for (...; ... != std::end(...); ...)
       */

      this.getCondition().(NEExpr).getRightOperand() = end and
      end.getTarget().hasQualifiedName("std", "end")
    )
  }
}

/**
 * Gets an iteration variable as identified by the initialization statement for the loop.
 * This predicate has the added benefit that it does not identify range-based loops,
 * which are irrelevant for this rule.
 */
private Variable getAnIterationVariable(ForStmt fs) {
  // for (int i = 0;)
  result = fs.getADeclaration()
  or
  // int i;
  // for (i = 0;)
  result.getAnAssignment() = fs.getInitialization().(ExprStmt).getExpr()
}

/**
 * Gets a variable that was accessed in the body of a `for` loop.
 */
private predicate hasAccessInBody(Variable v, ForStmt fs) {
  v.getAnAccess().getEnclosingStmt() = fs.getStmt().getAChild*()
}

from TotalArrayForStmt fs, Variable v
where
  not isExcluded(v, LoopsPackage::unusedLoopCounterForContainerIterationQuery()) and
  v = getAnIterationVariable(fs) and
  not hasAccessInBody(v, fs)
select fs, "Loop counter $@ is not used.", v, v.getName()
