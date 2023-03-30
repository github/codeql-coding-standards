/**
 * @id c/cert/do-not-pass-invalid-data-to-the-asctime-function
 * @name MSC33-C: Do not pass invalid data to the asctime() function
 * @description The data passed to the asctime() function is invalid. This can lead to buffer
 *              overflow.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/msc33-c
 *       security
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.dataflow.DataFlow

/**
 * The argument of a call to `asctime`
 */
class AsctimeArg extends Expr {
  AsctimeArg() {
    this =
      any(FunctionCall f | f.getTarget().hasGlobalName(["asctime", "asctime_r"])).getArgument(0)
  }
}

/**
 * Dataflow configuration for flow from a library function
 * to a call of function `asctime`
 */
class TmStructSafeConfig extends DataFlow::Configuration {
  TmStructSafeConfig() { this = "TmStructSafeConfig" }

  override predicate isSource(DataFlow::Node src) {
    src.asExpr()
        .(FunctionCall)
        .getTarget()
        .hasGlobalName(["localtime", "localtime_r", "localtime_s", "gmtime", "gmtime_r", "gmtime_s"])
  }

  override predicate isSink(DataFlow::Node sink) { sink.asExpr() instanceof AsctimeArg }
}

from AsctimeArg fc, TmStructSafeConfig config
where
  not isExcluded(fc, Contracts7Package::doNotPassInvalidDataToTheAsctimeFunctionQuery()) and
  not config.hasFlowToExpr(fc)
select fc,
  "The function `asctime` and `asctime_r` should be discouraged. Unsanitized input can overflow the output buffer."
