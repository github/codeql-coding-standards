/**
 * @id cpp/cert/honor-termination-replacement-handler-requirements
 * @name OOP56-CPP: Honor replacement handler requirements
 * @description Replacement handlers for termination or unexpected exceptions must terminate to
 *              ensure correct program behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/oop56-cpp
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.Handlers

from SetHandlerFunction handler
where
  not isExcluded(handler, InvariantsPackage::honorTerminationReplacementHandlerRequirementsQuery()) and
  (
    (handler.isTerminate() or handler.isUnexpected()) and
    not handler.exits()
  )
select handler, "Replacement handler does not terminate."
