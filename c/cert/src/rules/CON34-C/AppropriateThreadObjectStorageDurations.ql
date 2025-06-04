/**
 * @id c/cert/appropriate-thread-object-storage-durations
 * @name CON34-C: Declare objects shared between threads with appropriate storage durations
 * @description Accessing thread-local variables with automatic storage durations can lead to
 *              unpredictable program behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/con34-c
 *       correctness
 *       concurrency
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Objects
import codingstandards.cpp.Concurrency
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.commons.Alloc

from C11ThreadCreateCall tcc, Expr arg
where
  not isExcluded(tcc, Concurrency4Package::appropriateThreadObjectStorageDurationsQuery()) and
  tcc.getArgument(2) = arg and
  (
    exists(ObjectIdentity obj, Expr acc |
      obj.getASubobjectAccess() = acc and
      obj.getStorageDuration().isAutomatic() and
      exists(DataFlow::Node addrNode |
        (
          addrNode = DataFlow::exprNode(any(AddressOfExpr e | e.getOperand() = acc))
          or
          addrNode = DataFlow::exprNode(acc) and
          exists(ArrayToPointerConversion c | c.getExpr() = acc)
        ) and
        TaintTracking::localTaint(addrNode, DataFlow::exprNode(arg))
      )
    )
    or
    // TODO: This case is handling threadlocals in a useful way that's not intended to be covered
    // by the rule. See issue #801. The actual rule should expect no tss_t objects is used, and
    // this check that this is initialized doesn't seem to belong here. However, it is a useful
    // check in and of itself, so we should figure out if this is part of an optional rule we
    // haven't yet implemented and move this behavior there.
    exists(TSSGetFunctionCall tsg |
      TaintTracking::localTaint(DataFlow::exprNode(tsg), DataFlow::exprNode(arg)) and
      not exists(TSSSetFunctionCall tss, DataFlow::Node src |
        // there should be dataflow from somewhere (the same somewhere)
        // into each of the first arguments
        DataFlow::localFlow(src, DataFlow::exprNode(tsg.getArgument(0))) and
        DataFlow::localFlow(src, DataFlow::exprNode(tss.getArgument(0)))
      )
    )
  )
select tcc, "$@ not declared with appropriate storage duration", arg, "Shared object"
