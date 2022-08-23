/**
 * @id c/cert/toctou-race-conditions-while-accessing-files
 * @name FIO45-C: Avoid TOCTOU race conditions while accessing files
 * @description TOCTOU race conditions when accessing files can lead to vulnerability.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio45-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.standardlibrary.FileAccess
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

/**
 * A file opened as read-only that is never read from.
 */
class EmptyFOpenCall extends FOpenCall {
  EmptyFOpenCall() {
    this.isReadOnlyMode() and
    // FILE is only used as argument to close or in a NULL check
    forall(Expr x | this != x and DataFlow::localExprFlow(this, x) |
      fcloseCall(_, x)
      or
      exists(EqualityOperation eq | eq.getAnOperand() = x and eq.getAnOperand() = any(NULL n))
    )
  }
}

// The same file is opened multiple times in different modes
from EmptyFOpenCall emptyFopen, FOpenCall fopen
where
  not isExcluded(emptyFopen, IO4Package::toctouRaceConditionsWhileAccessingFilesQuery()) and
  not fopen.isReadOnlyMode() and
  globalValueNumber(emptyFopen.getFilenameExpr()) = globalValueNumber(fopen.getFilenameExpr())
select emptyFopen,
  "This call is trying to prevent an existing file from being overwritten by $@. An attacker might be able to exploit the race window between the two calls.",
  fopen, "another call"
