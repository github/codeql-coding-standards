/**
 * @id cpp/autosar/move-from-consume-parameters-rval-ref
 * @name A8-4-5: 'consume' parameters declared as X && shall always be moved from
 * @description 'consume' parameters declared as X && shall always be moved from.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a8-4-5
 *       correctness
 *       external/autosar/allocated-target/design
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.standardlibrary.Utility
import codingstandards.cpp.autosar

from ConsumeParameter p, FunctionCall c
where
  not isExcluded(c.getAnArgument(), MoveForwardPackage::moveFromConsumeParametersRvalRefQuery()) and
  not c instanceof StdMoveCall and
  p.getAnAccess() = c.getAnArgument()
select c.getAnArgument(),
  "The \"consume\" parameter `" + c.getAnArgument() +
    "` requires an explicit `std::move` at ths call site."
