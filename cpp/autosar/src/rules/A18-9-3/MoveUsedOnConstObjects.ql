/**
 * @id cpp/autosar/move-used-on-const-objects
 * @name A18-9-3: The std::move shall not be used on objects declared const or const&
 * @description The std::move shall not be used on objects declared const or const&.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-9-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.standardlibrary.Utility

from StdMoveCall x
where
  not isExcluded(x.getArgument(0), MoveForwardPackage::moveUsedOnConstObjectsQuery()) and
  (
    x.getArgument(0).getType().isConst()
    or
    x.getArgument(0).getType().(ReferenceType).getBaseType().isConst()
  )
select x.getArgument(0),
  "Implicit call to copy constructor use in std::move because argument has const type `" +
    x.getArgument(0).getType().getUnderlyingType() + "`."
