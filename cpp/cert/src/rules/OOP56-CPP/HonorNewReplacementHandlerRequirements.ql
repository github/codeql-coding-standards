/**
 * @id cpp/cert/honor-new-replacement-handler-requirements
 * @name OOP56-CPP: Honor replacement handler requirements
 * @description Replacement handlers for new must test for allocation errors.
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
  not isExcluded(handler, InvariantsPackage::honorNewReplacementHandlerRequirementsQuery()) and
  handler.isNewHandler() and
  not handler.onlyThrowsBadAlloc()
select handler, "Replacement handler for `new` throws an exception that is not `bad_alloc`."
