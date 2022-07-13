/**
 * @id cpp/autosar/forwarding-values-to-other-functions
 * @name A18-9-2: Rvalue references are forwarded with std::move and forwarding reference with std::forward
 * @description Rvalue references are forwarded with std::move and forwarding reference with
 *              std::forward.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-9-2
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.standardlibrary.Utility
import codingstandards.cpp.autosar

from FunctionCall c, Parameter a, string message
where
  not isExcluded(c, MoveForwardPackage::forwardingValuesToOtherFunctionsQuery()) and
  a.getAnAccess() = c.getAnArgument() and
  (
    c instanceof StdMoveCall and
    a instanceof ForwardParameter and
    message = "Function `std::forward` should be used for forwarding the forward reference $@."
    or
    c instanceof StdForwardCall and
    a instanceof ConsumeParameter and
    message = "Function `std::move` should be used for forwarding rvalue reference $@."
  )
select c, message, a, a.getName()
