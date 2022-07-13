/**
 * @id cpp/autosar/virtual-functions-introduced-in-final-class
 * @name A10-3-3: Virtual functions shall not be introduced in a final class
 * @description Virtual functions shall not be introduced in a final class.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a10-3-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isVirtualFunctionInFinalClass(VirtualFunction f) {
  exists(Class c | c.isFinal() and f.getDeclaringType() = c)
}

from VirtualFunction f
where
  not isExcluded(f, VirtualFunctionsPackage::virtualFunctionsIntroducedInFinalClassQuery()) and
  isVirtualFunctionInFinalClass(f) and
  not f.hasSpecifier("final") and
  not f.isDefaulted() and
  not f.isCompilerGenerated() and
  not f.getBlock().getLocation().hasLocationInfo("", 0, 0, 0, 0)
select f, "Non-final virtual function $@ is introduced in final class $@.", f, f.getName(),
  f.getDeclaringType(), f.getDeclaringType().getName()
