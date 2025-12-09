/**
 * @id cpp/misra/missing-catch-all-exception-handler-in-main
 * @name RULE-18-3-1: There should be at least one exception handler to catch all otherwise unhandled exceptions
 * @description The main function should have a catch-all exception handler (catch(...)) to catch
 *              all otherwise unhandled exceptions.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-18-3-1
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.EncapsulatingFunctions
import codingstandards.cpp.exceptions.ExceptionFlow
import codingstandards.cpp.exceptions.ExceptionSpecifications

/**
 * A function call in main that is not declared noexcept and is not within a catch-all
 * exception handler (catch(...)).
 */
class UncaughtFunctionCallInMain extends FunctionCall {
  UncaughtFunctionCallInMain() {
    getEnclosingFunction() instanceof MainFunction and
    not isNoExceptTrue(getTarget()) and
    not exists(TryStmt try |
      try = getATryStmt(this.getEnclosingStmt()) and
      try.getCatchClause(_) instanceof CatchAnyBlock
    )
  }

  /**
   * We only want to report one counter-example indicating a missing catch(...), so this holds only
   * for the first one we find.
   */
  predicate isFirst() {
    this =
      rank[1](UncaughtFunctionCallInMain fc |
        any()
      |
        fc order by fc.getLocation().getStartLine(), fc.getLocation().getStartColumn()
      )
  }
}

from MainFunction f, UncaughtFunctionCallInMain fc
where
  not isExcluded(f, Exceptions3Package::missingCatchAllExceptionHandlerInMainQuery()) and
  fc.isFirst()
select f,
  "Main function has a $@ which is not within a try block with a catch-all ('catch(...)') handler.",
  fc, "function call that may throw"
