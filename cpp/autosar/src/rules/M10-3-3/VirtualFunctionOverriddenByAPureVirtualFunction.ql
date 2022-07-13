/**
 * @id cpp/autosar/virtual-function-overridden-by-a-pure-virtual-function
 * @name M10-3-3: A virtual function shall only be overridden by a pure virtual function if itself is pure virtual
 * @description A virtual function shall only be overridden by a pure virtual function if it is
 *              itself declared as pure virtual.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/m10-3-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from VirtualFunction f1, PureVirtualFunction f2
where f2.overrides(f1) and not f1 instanceof PureVirtualFunction
select f1, "$@ is not a pure virtual function, and it is overriden by pure virtual function $@", f1,
  "Overridden function", f2, "Overriding function"
