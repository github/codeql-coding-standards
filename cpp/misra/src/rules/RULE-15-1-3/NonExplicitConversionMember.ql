/**
 * @id cpp/misra/non-explicit-conversion-member
 * @name RULE-15-1-3: Conversion operators and constructors that are callable with a single argument shall be explicit
 * @description Implicit conversions can lead to unexpected behavior that is preventable by
 *              declaring conversion operators and constructors as explicit.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-15-1-3
 *       scope/single-translation-unit
 *       correctness
 *       readability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

predicate isCallableWithOneArgument(Constructor c) {
  // At least one parameter
  c.getNumberOfParameters() > 0 and
  // At most one parameter without an initializer
  count(Parameter p | p = c.getAParameter() and not p.hasInitializer()) <= 1
}

from Element x, string message
where
  not isExcluded(x, Classes2Package::nonExplicitConversionMemberQuery()) and
  (
    exists(Constructor c |
      x = c and
      not c.isExplicit() and
      not c instanceof CopyConstructor and
      not c instanceof MoveConstructor and
      isCallableWithOneArgument(c) and
      message =
        "Constructor '" + c.getName() +
          "' that is callable with a single argument shall be explicit."
    )
    or
    exists(ConversionOperator co |
      x = co and
      not co.isExplicit() and
      message = "Conversion operator shall be explicit."
    )
  )
select x, message
