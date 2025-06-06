/**
 * @id cpp/misra/no-variadic-function-macros
 * @name RULE-21-10-1: The features of <cstdarg> shall not be used
 * @description Using <cstdarg> features like va_list, va_arg, va_start, va_end and va_copy bypasses
 *              compiler type checking and leads to undefined behavior when used incorrectly.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-10-1
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

class VaListType extends Type {
  VaListType() {
    this.getName() = "va_list" or
    this.(SpecifiedType).getBaseType() instanceof VaListType or
    this.(TypedefType).getBaseType() instanceof VaListType
  }
}

from Element element, string message
where
  not isExcluded(element, BannedAPIsPackage::noVariadicFunctionMacrosQuery()) and
  (
    element.(Variable).getType() instanceof VaListType and
    (
      if element instanceof Parameter
      then
        message =
          "Declaration of parameter '" + element.(Parameter).getName() + "' of type 'va_list'."
      else
        message =
          "Declaration of variable '" + element.(Variable).getName() + "' of type 'va_list'."
    )
    or
    element instanceof BuiltInVarArgsStart and
    message = "Call to 'va_start'."
    or
    element instanceof BuiltInVarArgsEnd and
    message = "Call to 'va_end'."
    or
    element instanceof BuiltInVarArg and
    message = "Call to 'va_arg'."
    or
    element instanceof BuiltInVarArgCopy and
    message = "Call to 'va_copy'."
    or
    element.(TypedefType).getBaseType() instanceof VaListType and
    message =
      "Declaration of typedef '" + element.(TypedefType).getName() + "' aliasing 'va_list' type."
  )
select element, message
