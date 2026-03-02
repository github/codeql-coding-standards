/**
 * @id cpp/misra/use-of-deprecated-allocator-void
 * @name RULE-4-1-2: Specialization allocator<void> is a deprecated language feature and should not be used
 * @description Deprecated language features such as allocator<void> are only supported for
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
import codingstandards.cpp.standardlibrary.Memory

class DeprecatedDefaultAllocator extends ClassTemplateSpecialization {
  DeprecatedDefaultAllocator() {
    this.getPrimaryTemplate() instanceof DefaultAllocator and
    this.getTemplateArgument(0) instanceof VoidType
  }
}

from TypeMention tm, DeprecatedDefaultAllocator x
where
  not isExcluded(tm, Toolchain3Package::useOfDeprecatedAllocatorVoidQuery()) and
  tm.getMentionedType() = x
select tm, "Use of deprecated allocator specialization 'std::allocator<void>'."
