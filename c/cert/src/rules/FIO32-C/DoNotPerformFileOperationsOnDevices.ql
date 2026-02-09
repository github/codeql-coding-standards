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
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.security.FunctionWithWrappers
import semmle.code.cpp.security.FlowSources
import semmle.code.cpp.ir.IR
import semmle.code.cpp.ir.dataflow.TaintTracking
import TaintedPath::PathGraph

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

/**
 * Holds for a variable that has any kind of upper-bound check anywhere in the program.
 * This is biased towards being inclusive and being a coarse overapproximation because
 * there are a lot of valid ways of doing an upper bounds checks if we don't consider
 * where it occurs, for example:
 * ```cpp
 *   if (x < 10) { sink(x); }
 *
 *   if (10 > y) { sink(y); }
 *
 *   if (z > 10) { z = 10; }
 *   sink(z);
 * ```
 */
predicate hasUpperBoundsCheck(Variable var) {
  exists(RelationalOperation oper, VariableAccess access |
    oper.getAnOperand() = access and
    access.getTarget() = var and
    // Comparing to 0 is not an upper bound check
    not oper.getAnOperand().getValue() = "0"
  )
}

module TaintedPathConfiguration implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) { node instanceof FlowSource }

  predicate isSink(DataFlow::Node node) {
    exists(FileFunction fileFunction |
      fileFunction.outermostWrapperFunctionCall(node.asIndirectArgument(), _)
    )
  }

  predicate isBarrier(DataFlow::Node node) {
    node.asExpr().(Call).getTarget().getUnspecifiedType() instanceof ArithmeticType
    or
    exists(LoadInstruction load, Variable checkedVar |
      load = node.asInstruction() and
      checkedVar = load.getSourceAddress().(VariableAddressInstruction).getAstVariable() and
      hasUpperBoundsCheck(checkedVar)
    )
  }
}

module TaintedPath = TaintTracking::Global<TaintedPathConfiguration>;

from
  FileFunction fileFunction, Expr taintedArg, FlowSource taintSource,
  TaintedPath::PathNode sourceNode, TaintedPath::PathNode sinkNode, string callChain
where
  not isExcluded(taintedArg, IO3Package::doNotPerformFileOperationsOnDevicesQuery()) and
  taintedArg = sinkNode.getNode().asIndirectArgument() and
  fileFunction.outermostWrapperFunctionCall(taintedArg, callChain) and
  TaintedPath::flowPath(sourceNode, sinkNode) and
  taintSource = sourceNode.getNode()
select taintedArg, sourceNode, sinkNode,
  "This argument to a file access function is derived from $@ and then passed to " + callChain + ".",
  taintSource, "user input (" + taintSource.getSourceType() + ")"
