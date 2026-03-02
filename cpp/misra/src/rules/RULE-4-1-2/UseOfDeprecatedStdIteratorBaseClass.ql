/**
 * @id cpp/misra/use-of-deprecated-std-iterator-base-class
 * @name RULE-4-1-2: Base class std::iterator is a deprecated language feature and should not be used
 * @description Deprecated language features such as extending std::iterator are only supported for
 *              backwards compatibility; these are considered bad practice, or have been superceded
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
import codingstandards.cpp.StdNamespace

from TypeMention tm, ClassTemplateInstantiation c
where
  not isExcluded(tm, Toolchain3Package::useOfDeprecatedStdIteratorBaseClassQuery()) and
  tm.getMentionedType() = c and
  c.getNamespace() instanceof StdNS and
  c.getSimpleName() = "iterator"
select tm, "Use of deprecated base class 'std::iterator'."
