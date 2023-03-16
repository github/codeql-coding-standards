/**
 * @id c/cert/do-not-access-shared-objects-in-signal-handlers
 * @name SIG31-C: Do not access shared objects in signal handlers
 * @description Do not access shared objects in signal handlers.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/sig31-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, SignalHandlersPackage::doNotAccessSharedObjectsInSignalHandlersQuery()) and
select
