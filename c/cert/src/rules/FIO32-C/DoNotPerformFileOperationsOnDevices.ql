/**
 * @id c/cert/do-not-perform-file-operations-on-devices
 * @name FIO32-C: Do not perform operations on devices that are only appropriate for files
 * @description Performing file operations on devices can result in crashes.
 * @kind path-problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/fio32-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.security.FunctionWithWrappers
import semmle.code.cpp.security.Security
import semmle.code.cpp.security.TaintTracking
import TaintedWithPath

// Query TaintedPath.ql from the CodeQL standard library
/**
 * A function for opening a file.
 */
class FileFunction extends FunctionWithWrappers {
  FileFunction() {
    exists(string nme | this.hasGlobalName(nme) |
      nme = ["fopen", "_fopen", "_wfopen", "open", "_open", "_wopen"]
      or
      // create file function on windows
      nme.matches("CreateFile%")
    )
    or
    this.hasQualifiedName("std", "fopen")
    or
    // on any of the fstream classes, or filebuf
    exists(string nme | this.getDeclaringType().hasQualifiedName("std", nme) |
      nme = ["basic_fstream", "basic_ifstream", "basic_ofstream", "basic_filebuf"]
    ) and
    // we look for either the open method or the constructor
    (this.getName() = "open" or this instanceof Constructor)
  }

  // conveniently, all of these functions take the path as the first parameter!
  override predicate interestingArg(int arg) { arg = 0 }
}

class TaintedPathConfiguration extends TaintTrackingConfiguration {
  override predicate isSink(Element tainted) {
    exists(FileFunction fileFunction | fileFunction.outermostWrapperFunctionCall(tainted, _))
  }
}

from
  FileFunction fileFunction, Expr taintedArg, Expr taintSource, PathNode sourceNode,
  PathNode sinkNode, string taintCause, string callChain
where
  not isExcluded(taintedArg, IO3Package::doNotPerformFileOperationsOnDevicesQuery()) and
  fileFunction.outermostWrapperFunctionCall(taintedArg, callChain) and
  taintedWithPath(taintSource, taintedArg, sourceNode, sinkNode) and
  isUserInput(taintSource, taintCause)
select taintedArg, sourceNode, sinkNode,
  "This argument to a file access function is derived from $@ and then passed to " + callChain,
  taintSource, "user input (" + taintCause + ")"
