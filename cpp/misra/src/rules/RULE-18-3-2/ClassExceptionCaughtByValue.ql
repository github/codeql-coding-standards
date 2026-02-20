/**
 * @id cpp/misra/class-exception-caught-by-value
 * @name RULE-18-3-2: An exception of class type shall be caught by const reference or reference
 * @description Catching exception classes by value can lead to slicing, which can result in
 *              unexpected behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-3-2
 *       scope/single-translation-unit
 *       correctness
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from CatchBlock catch, Type type
where
  not isExcluded(catch, Exceptions3Package::classExceptionCaughtByValueQuery()) and
  type = catch.getParameter().getType() and
  type.stripTopLevelSpecifiers() instanceof Class
select catch, "Catch block catches a class type '" + type + "' by value, which can lead to slicing."
