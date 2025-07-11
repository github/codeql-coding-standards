/**
 * @id c/cert/only-use-values-for-fsetpos-that-are-returned-from-fgetpos
 * @name FIO44-C: Only use values for fsetpos() that are returned from fgetpos()
 * @description Arguments for `fsetpos()` can only be obtained from calls to `fgetpos()`.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/fio44-c
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.new.DataFlow

class FgetposCall extends FunctionCall {
  FgetposCall() { this.getTarget().hasGlobalOrStdName("fgetpos") }
}

class FsetposCall extends FunctionCall {
  FsetposCall() { this.getTarget().hasGlobalOrStdName("fsetpos") }
}

module FposDFConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    // source must be the second parameter of a FgetposCall call
    source.asDefiningArgument() = any(FgetposCall c).getArgument(1)
  }

  predicate isSink(DataFlow::Node sink) {
    // sink must be the second parameter of a FsetposCall call
    sink.asIndirectExpr() = any(FsetposCall c).getArgument(1)
  }
}

module FposDFFlow = DataFlow::Global<FposDFConfig>;

from FsetposCall fsetpos
where
  not isExcluded(fsetpos.getArgument(1),
    IO2Package::onlyUseValuesForFsetposThatAreReturnedFromFgetposQuery()) and
  not exists(DataFlow::Node n | n.asIndirectExpr() = fsetpos.getArgument(1) | FposDFFlow::flowTo(n))
select fsetpos.getArgument(1),
  "The position argument of a call to `fsetpos()` should be obtained from a call to `fgetpos()`."
