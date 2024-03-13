/**
 * @id c/misra/file-open-for-read-and-write-on-different-streams
 * @name RULE-22-3: The same file shall not be open for read and write access at the same time on different streams
 * @description Accessing the same file for read and write from different streams is undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-3
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.standardlibrary.FileAccess
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.controlflow.SubBasicBlocks

/**
 * Models calls to `fopen` with different read/write modes
 */
class FOpenSBB extends SubBasicBlockCutNode {
  FOpenSBB() {
    this instanceof FOpenCall or
    this instanceof FileCloseFunctionCall
  }
}

SubBasicBlock followsOpen(FOpenCall fopen) {
  result = fopen
  or
  exists(SubBasicBlock mid |
    result = mid.getASuccessor() and
    mid = followsOpen(fopen) and
    // stop recursion when the first stream is closed
    not DataFlow::localExprFlow(fopen, result.(FileCloseFunctionCall).getFileExpr())
  )
}

class MatchedFOpenCall extends FOpenCall {
  FOpenCall pair;

  MatchedFOpenCall() {
    not pair = this and
    pair.getEnclosingFunction() = this.getEnclosingFunction() and
    this = followsOpen(pair)
  }

  FOpenCall getMatch() { result = pair }
}

from MatchedFOpenCall fst, FOpenCall snd
where
  not isExcluded(fst, IO3Package::fileOpenForReadAndWriteOnDifferentStreamsQuery()) and
  // must be opening the same filename
  snd = fst.getMatch() and
  globalValueNumber(fst.getFilenameExpr()) = globalValueNumber(snd.getFilenameExpr()) and
  (
    // different open mode
    fst.isReadMode() and snd.isWriteMode()
    or
    fst.isWriteMode() and snd.isReadMode()
  )
select fst,
  "The same file was already opened $@. Files should not be read and written at the same time using different streams.",
  snd, "here"
