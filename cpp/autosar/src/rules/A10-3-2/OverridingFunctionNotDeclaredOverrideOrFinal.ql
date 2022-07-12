/**
 * @id cpp/autosar/overriding-function-not-declared-override-or-final
 * @name A10-3-2: Each overriding virtual function shall be declared with the override or final specifier
 * @description Each overriding virtual function shall be declared with either the override or final
 *              specifier.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a10-3-2
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Class

from VirtualFunction vf, MemberFunction m
where
  not isExcluded(vf, VirtualFunctionsPackage::overridingFunctionNotDeclaredOverrideOrFinalQuery()) and
  m.overrides(vf) and
  not (m instanceof OverrideFunction or m instanceof FinalFunction) and
  not m.isCompilerGenerated()
select m, "Overriding function $@ not declared with 'final' or 'override' specifier.", m,
  m.getName()
