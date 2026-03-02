/**
 * @id cpp/misra/use-of-deprecated-std-allocator-member
 * @name RULE-4-1-2: Certain members of std::allocator are deprecated language features and should not be used
 * @description Deprecated language features such as certain members of std::allocator are only
 *              supported for backwards compatibility; these are considered bad practice, or have
 *              been superceded by better alternatives.
 * @kind problem
 * @precision very_high
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

abstract class DeprecatedUse extends Element {
  abstract Locatable getAUseLocation();

  abstract string getAUseDescription();
}

class DeprecatedAllocatorUsingMember extends UsingAliasTypedefType, DeprecatedUse {
  ClassTemplateInstantiation cti;

  DeprecatedAllocatorUsingMember() {
    this.getDeclaringType().isFromTemplateInstantiation(cti) and
    cti.getTemplate() instanceof DefaultAllocator and
    this.hasName([
        "pointer", "const_pointer", "reference", "const_reference", "value_type", "size_type",
        "difference_type"
      ])
  }

  override Locatable getAUseLocation() { result.(TypeMention).getMentionedType() = this }

  override string getAUseDescription() {
    result = "Use of deprecated allocator member 'std::allocator<void>::pointer'."
  }
}

class DeprecatedAllocatorMemberFunction extends MemberFunction, DeprecatedUse {
  ClassTemplateInstantiation cti;

  DeprecatedAllocatorMemberFunction() {
    this.getDeclaringType().isFromTemplateInstantiation(cti) and
    cti.getTemplate() instanceof DefaultAllocator and
    (
      this.hasName(["address", "max_size", "construct", "destroy"])
      or
      this.hasName("allocate") and this.getNumberOfParameters() = 2
    )
  }

  override Locatable getAUseLocation() { result.(FunctionCall).getTarget() = this }

  override string getAUseDescription() {
    result = "Use of deprecated allocator member 'std::allocator<void>::" + this.getName() + "'."
  }
}

class DeprecatedAllocatorMemberClass extends ClassTemplateInstantiation, DeprecatedUse {
  DeprecatedAllocatorMemberClass() {
    this.getDeclaringType() instanceof DefaultAllocator and
    this.getSimpleName() = "rebind"
  }

  override Locatable getAUseLocation() { result.(TypeMention).getMentionedType() = this }

  override string getAUseDescription() {
    result = "Use of deprecated allocator member class 'std::allocator::rebind'."
  }
}

from DeprecatedUse deprecated, Locatable use
where
  not isExcluded(use, Toolchain3Package::useOfDeprecatedStdAllocatorMemberQuery()) and
  use = deprecated.getAUseLocation()
select use, deprecated.getAUseDescription()
