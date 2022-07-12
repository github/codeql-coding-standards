/**
 * @id cpp/autosar/virtual-functions-shall-contain-one-specifier
 * @name A10-3-1: Virtual function declaration shall contain exactly one specifier
 * @description Virtual function declaration shall contain exactly one of the three specifiers: (1)
 *              virtual, (2) override, (3) final.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a10-3-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class

from MemberFunction f
where
  not isExcluded(f, VirtualFunctionsPackage::virtualFunctionsShallContainOneSpecifierQuery()) and
  (
    (f instanceof OverrideFunction or f instanceof FinalFunction) and
    f.hasSpecifier("declared_virtual")
  )
  or
  f instanceof OverrideFunction and f instanceof FinalFunction
select f, "Virtual function $@ declared with multiple specifiers.", f, f.getName()
