/**
 * @id c/cert/do-not-return-from-a-computational-exception-handler
 * @name SIG35-C: Do not return from a computational exception signal handler
 * @description Do not return from a computational exception signal handler.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/sig35-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, SignalHandlersPackage::doNotReturnFromAComputationalExceptionHandlerQuery()) and
select
