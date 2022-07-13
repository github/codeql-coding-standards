/**
 * @id c/cert/only-use-values-for-fsetpos-that-are-returned-from-fgetpos
 * @name FIO44-C: Only use values for fsetpos() that are returned from fgetpos()
 * @description Arguments for `fsetpos()` can only be obtained from calls to `fgetpos()`.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/fio44-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow

class FgetposCall extends FunctionCall {
  FgetposCall() { this.getTarget().hasGlobalOrStdName("fgetpos") }
}

class FsetposCall extends FunctionCall {
  FsetposCall() { this.getTarget().hasGlobalOrStdName("fsetpos") }
}

class FposDFConf extends DataFlow::Configuration {
  FposDFConf() { this = "FposDFConf" }

  override predicate isSource(DataFlow::Node source) {
    // source must be the second parameter of a FgetposCall call
    source = DataFlow::definitionByReferenceNodeFromArgument(any(FgetposCall c).getArgument(1))
  }

  override predicate isSink(DataFlow::Node sink) {
    // sink must be the second parameter of a FsetposCall call
    sink.asExpr() = any(FsetposCall c).getArgument(1)
  }
}

from FsetposCall fsetpos
where
  not isExcluded(fsetpos.getArgument(1),
    IO2Package::onlyUseValuesForFsetposThatAreReturnedFromFgetposQuery()) and
  not any(FposDFConf dfConf).hasFlowToExpr(fsetpos.getArgument(1))
select fsetpos.getArgument(1),
  "The position argument of a call to `fsetpos()` should be obtained from a call to `fgetpos()`."
