/**
 * @id cpp/autosar/inconsistent-noexcept-false-specification
 * @name A15-4-3: Inconsistent noexcept(false) specification on function declaration
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
import codingstandards.cpp.exceptions.ExceptionFlow
import IncompatibleNoexceptSpecifications

from InconsistentNoExceptFunction f, FunctionDeclarationEntry fde1, FunctionDeclarationEntry fde2
where
  not isExcluded(f, Exceptions2Package::inconsistentNoexceptFalseSpecificationQuery()) and
  not isExcluded(fde1, Exceptions2Package::inconsistentNoexceptFalseSpecificationQuery()) and
  not isExcluded(fde2, Exceptions2Package::inconsistentNoexceptFalseSpecificationQuery()) and
  fde1 = f.getANoExceptFalseDeclEntry() and
  fde2 = f.getANoExceptTrueDeclEntry() and
  not exists(getAFunctionThrownType(f, _)) and
  f.hasDefinition()
select fde1,
  "Function " + f.getName() +
    " does not throw an exception, but is declared here as noexcept(false) which is inconsistent with $@ which declare it as noexcept(true).",
  fde2, "other declarations"
