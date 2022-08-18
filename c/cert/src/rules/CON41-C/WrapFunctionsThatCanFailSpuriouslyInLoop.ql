/**
 * @id c/cert/wrap-functions-that-can-fail-spuriously-in-loop
 * @name CON41-C: Wrap functions that can fail spuriously in a loop
 * @description Failing to wrap a function that may fail spuriously may result in unreliable program
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/con41-c
 *       correctness
 *       concurrency
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

/**
 * Models calls to routines in the `stdatomic` library. Note that these
 * are typically implemented as macros within Clang and GCC's standard
 * libraries.
 */
class SpuriouslyFailingFunctionCallType extends MacroInvocation {
  SpuriouslyFailingFunctionCallType() {
    getMacroName() = ["atomic_compare_exchange_weak", "atomic_compare_exchange_weak_explicit"]
  }
}

from SpuriouslyFailingFunctionCallType fc
where
  not isExcluded(fc, Concurrency3Package::wrapFunctionsThatCanFailSpuriouslyInLoopQuery()) and
  (
    exists(StmtParent sp | sp = fc.getStmt() and not sp.(Stmt).getParentStmt*() instanceof Loop)
    or
    exists(StmtParent sp |
      sp = fc.getExpr() and not sp.(Expr).getEnclosingStmt().getParentStmt*() instanceof Loop
    )
  )
select fc, "Function that can spuriously fail not wrapped in a loop."
