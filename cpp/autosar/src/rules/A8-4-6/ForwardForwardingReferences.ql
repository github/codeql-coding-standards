/**
 * @id cpp/autosar/forward-forwarding-references
 * @name A8-4-6: "forward" parameters declared as T && shall always be forwarded
 * @description "forward" parameters declared as T && shall always be forwarded.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a8-4-6
 *       correctness
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.standardlibrary.Utility
import codingstandards.cpp.autosar

from ForwardParameter p, FunctionCall c
where
  not isExcluded(c.getAnArgument(), MoveForwardPackage::forwardForwardingReferencesQuery()) and
  not c instanceof StdForwardCall and
  p.getAnAccess() = c.getAnArgument()
select c.getAnArgument(),
  "The \"forward\" parameter `" + c.getAnArgument() +
    "` requires an explicit `std::forward` at ths call site."
