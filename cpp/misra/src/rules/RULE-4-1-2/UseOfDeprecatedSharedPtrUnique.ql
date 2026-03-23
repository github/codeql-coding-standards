/**
 * @id cpp/misra/use-of-deprecated-shared-ptr-unique
 * @name RULE-4-1-2: Observer member shared_ptr::unique is a deprecated language feature and should not be used
 * @description Deprecated language features such as shared_ptr::unique are only supported for
 *              backwards compatibility; these are considered bad practice, or have been superseded
 *              by better alternatives.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1-2
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from MemberFunction mf, FunctionCall fc
where
  not isExcluded(fc, Toolchain3Package::useOfDeprecatedSharedPtrUniqueQuery()) and
  mf = fc.getTarget() and
  mf.hasName("unique") and
  mf.getDeclaringType().(ClassTemplateInstantiation).hasQualifiedName("std", "shared_ptr")
select fc, "Call to deprecated member function 'std::shared_ptr::unique'."
