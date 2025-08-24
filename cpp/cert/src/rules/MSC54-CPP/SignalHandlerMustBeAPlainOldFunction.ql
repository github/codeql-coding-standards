/**
 * @id cpp/cert/signal-handler-must-be-a-plain-old-function
 * @name MSC54-CPP: A signal handler must be a plain old function
 * @description Signal handlers that are not a plain old function can result in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc54-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p6
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

class SigHandlerFunctionCall extends FunctionCall {
  Function handler;

  SigHandlerFunctionCall() {
    getTarget().hasGlobalOrStdName("signal") and
    handler = getAnArgument().(FunctionAccess).getTarget()
  }

  Function getHandler() { handler = result }
}

class PlainOldFunction extends Function {
  PlainOldFunction() {
    // must have extern "C" linkage
    hasCLinkage() and
    // must not call try or catch
    not exists(StmtParent s |
      this = s.getControlFlowScope() and
      (
        // must not try / catch
        s instanceof TryStmt
        or
        // must not throw anything
        s instanceof ThrowExpr
        or
        // must not call new/delete
        s instanceof NewExpr
        or
        s instanceof DeleteExpr
      )
    ) and
    // must not use dynamic_cast
    not exists(DynamicCast dc | dc.getEnclosingFunction() = this)
  }
}

/*
 * Note that this query only finds functions directly passed to signal handler
 * functions.
 */

from SigHandlerFunctionCall hc
where
  not isExcluded(hc, InvariantsPackage::signalHandlerMustBeAPlainOldFunctionQuery()) and
  not hc.getHandler() instanceof PlainOldFunction
select hc, "Installed handler is not a plain old function."
