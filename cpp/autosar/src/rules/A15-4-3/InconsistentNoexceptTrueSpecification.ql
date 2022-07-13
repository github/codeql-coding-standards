/**
 * @id cpp/autosar/inconsistent-noexcept-true-specification
 * @name A15-4-3: Inconsistent noexcept(true) specification on function declaration
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

from
  InconsistentNoExceptFunction f, FunctionDeclarationEntry fde1, FunctionDeclarationEntry fde2,
  ThrowingExpr te
where
  not isExcluded(f, Exceptions2Package::inconsistentNoexceptTrueSpecificationQuery()) and
  not isExcluded(fde1, Exceptions2Package::inconsistentNoexceptTrueSpecificationQuery()) and
  not isExcluded(fde2, Exceptions2Package::inconsistentNoexceptTrueSpecificationQuery()) and
  fde1 = f.getANoExceptTrueDeclEntry() and
  fde2 = f.getANoExceptFalseDeclEntry() and
  exists(getAFunctionThrownType(f, te)) and
  f.hasDefinition()
select fde1,
  "Function " + f.getName() +
    " $@ but is declared here as noexcept(true) and is inconsistent with $@ which declare it as noexcept(false).",
  te, "throws an exception", fde2, "other declarations"
