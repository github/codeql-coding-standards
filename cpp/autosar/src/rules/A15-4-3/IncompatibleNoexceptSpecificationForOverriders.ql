/**
 * @id cpp/autosar/incompatible-noexcept-specification-for-overriders
 * @name A15-4-3: The noexcept specification of a function shall be identical or more restrictive between a virtual member function and an overrider
 * @description The noexcept specification of a function shall be identical or more restrictive
 *              between a virtual member function and an overrider.
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
import codingstandards.cpp.exceptions.ExceptionSpecifications

/**
 * Return a unique declaration entry which is noexcept(true).
 *
 * In cases where a function is inconsistently noexcept specified, we want to report an declaration
 * entry which is noexcept(true), with a preference to report the definition.
 */
FunctionDeclarationEntry getNoExceptTrueDecl(Function f) {
  if isFDENoExceptTrue(f.getDefinition())
  then result = f.getDefinition()
  else
    result =
      rank[1](FunctionDeclarationEntry fde |
        fde = f.getADeclarationEntry() and isFDENoExceptTrue(fde)
      |
        fde order by fde.getName()
      )
}

from VirtualFunction mf, MemberFunction overrider
where
  not isExcluded(overrider,
    Exceptions2Package::incompatibleNoexceptSpecificationForOverridersQuery()) and
  mf.getAnOverridingFunction() = overrider and
  isNoExceptTrue(mf) and
  not isNoExceptTrue(overrider)
select overrider,
  "The function " + overrider.getName() +
    " overrides $@ which is specified noexcept(true), but is specified as the less restrictive noexcept(false).",
  getNoExceptTrueDecl(mf), "this virtual member function"
