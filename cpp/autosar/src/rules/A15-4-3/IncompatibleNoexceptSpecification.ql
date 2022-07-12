/**
 * @id cpp/autosar/incompatible-noexcept-specification
 * @name A15-4-3: The noexcept specification of a function shall be identical across all translation units
 * @description The noexcept specification of a function shall be identical across all translation
 *              units.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a15-4-3
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import IncompatibleNoexceptSpecifications

from InconsistentNoExceptFunction f, FunctionDeclarationEntry fde1, FunctionDeclarationEntry fde2
where
  not isExcluded(f, Exceptions2Package::incompatibleNoexceptSpecificationQuery()) and
  not isExcluded(fde1, Exceptions2Package::incompatibleNoexceptSpecificationQuery()) and
  not isExcluded(fde2, Exceptions2Package::incompatibleNoexceptSpecificationQuery()) and
  fde1 = f.getANoExceptFalseDeclEntry() and
  fde2 = f.getANoExceptTrueDeclEntry() and
  not f.hasDefinition()
select fde1,
  "Function " + f.getName() +
    " is declared here as noexcept(false), but is declared $@ with noexcept(true).", fde2, "here"
