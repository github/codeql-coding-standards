/**
 * @id cpp/autosar/special-function-missing-no-except-specification
 * @name A15-5-1: All user-provided class destructors, deallocation functions, move constructors, move assignment operators and swap functions shall have a noexcept exception specification
 * @description All user-provided class destructors, deallocation functions, move constructors, move
 *              assignment operators and swap functions shall have a noexcept exception
 *              specification.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a15-5-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.exceptions.SpecialFunctionExceptions
import codingstandards.cpp.exceptions.ExceptionSpecifications

from SpecialFunction f, string message
where
  not isExcluded(f, Exceptions2Package::specialFunctionMissingNoExceptSpecificationQuery()) and
  not isFDENoExceptTrue(f.getDefinition()) and
  not f.isCompilerGenerated() and
  not f.isDeleted() and
  not f.isDefaulted() and
  (
    isNoExceptExplicitlyFalse(f) and
    message =
      "Special function " + f.getQualifiedName() +
        " has a noexcept(false) specification that permits exceptions."
    or
    isNoExceptTrue(f) and
    message =
      f.getQualifiedName() +
        " has an implicit noexcept(true) specification but should make that explicit."
    or
    not isNoExceptTrue(f) and
    not isNoExceptExplicitlyFalse(f) and
    message =
      "Special function " + f.getQualifiedName() +
        " has an implicit noexcept(false) specification that permits exceptions."
  )
select f, message
