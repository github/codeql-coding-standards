/**
 * @id cpp/autosar/inconsistent-checked-exceptions
 * @name A15-4-5: Checked exceptions that could be thrown from a function should be consistently specified
 * @description Checked exceptions that could be thrown from a function shall be specified
 *              identically in all function declarations and for all overriders.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a15-4-5
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.autosar.CheckedException

from
  FunctionDeclarationEntry fde, Function f, CheckedException et, FunctionDeclarationEntry fdeOther
where
  not isExcluded(fde, Exceptions2Package::inconsistentCheckedExceptionsQuery()) and
  not isExcluded(f, Exceptions2Package::inconsistentCheckedExceptionsQuery()) and
  fde = f.getADeclarationEntry() and
  fdeOther = f.getADeclarationEntry() and
  // There exists at least one function declaration entry for this function which lists `et` as a thrown exception type
  et = getADeclaredThrowsCheckedException(fdeOther) and
  // But this function declaration entry does not list it
  not et = getADeclaredThrowsCheckedException(fde)
select fde,
  "Function declaration entry for " + f.getName() +
    " is missing @throw entry for checked exception $@ specified on $@.", et, et.getName(), fde,
  "other declaration."
