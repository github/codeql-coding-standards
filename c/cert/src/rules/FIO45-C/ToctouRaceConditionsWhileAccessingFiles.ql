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
import codingstandards.cpp.ReadErrorsAndEOF
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

/**
 * A function call that opens a file as read-only
 * but does not read the content of the file.
 */
class EmptyFOpenCall extends FOpenCall {
  EmptyFOpenCall() {
    this.isReadOnlyMode() and
    // the FILE is only used as argument to close or in a NULL check
    not exists(Expr x |
      this != x and
      DataFlow::localExprFlow(this, x) and
      not closed(x) and
      exists(EQExpr eq |
        eq.getAnOperand() = x and eq.getAnOperand() = any(NULLMacro m).getAnInvocation().getExpr()
      )
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
  "This call is trying to prevent an exsisting file to be overwritten by $@. An attacker might be able to exploit the race window between the two calls.",
  fopen, "another call"
