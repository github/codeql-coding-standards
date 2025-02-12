/**
 * @id cpp/autosar/argument-to-forward-subsequently-used
 * @name A18-9-4: An argument to std::forward shall not be subsequently used
 * @description An argument to std::forward shall not be subsequently used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a18-9-4
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.standardlibrary.Utility
import semmle.code.cpp.dataflow.DataFlow

from StdForwardCall f, Access a
where
  not isExcluded(a, MoveForwardPackage::movedFromObjectReadAccessedQuery()) and
  exists(DataFlow::DefinitionByReferenceNode def |
    def.asDefiningArgument() = f and
    DataFlow::localFlow(def, DataFlow::exprNode(a))
  )
select a, "The argument $@ of `std::forward` may be indeterminate when accessed at this location.",
  f.getArgument(0), f.getArgument(0).toString()
