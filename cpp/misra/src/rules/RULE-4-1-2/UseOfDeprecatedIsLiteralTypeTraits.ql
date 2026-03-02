/**
 * @id cpp/misra/use-of-deprecated-is-literal-type-traits
 * @name RULE-4-1-2: The is-literal type traits are deprecated language features and should not be used
 * @description Deprecated language features such as is-literal type traits are only supported for
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

class IsLiteralTypeTemplate extends TemplateClass {
  IsLiteralTypeTemplate() { this.hasQualifiedName("std", "is_literal_type") }
}

class IsLiteralTypeVariable extends TemplateVariable {
  IsLiteralTypeVariable() { this.hasQualifiedName("std", "is_literal_type") }
}

from Element usage, string type, string useKind
where
  not isExcluded(usage, Toolchain3Package::useOfDeprecatedIsLiteralTypeTraitsQuery()) and
  (
    exists(ClassTemplateInstantiation c |
      c.getTemplate() instanceof IsLiteralTypeTemplate and
      usage.(TypeMention).getMentionedType() = c and
      type = "std::is_literal_type" and
      useKind = "instantiation"
    )
    or
    exists(VariableTemplateInstantiation v |
      v.getTemplate() instanceof IsLiteralTypeVariable and
      usage.(VariableAccess).getTarget() = v and
      type = "std::is_literal_type" and
      useKind = "instantiation"
    )
    or
    exists(ClassTemplateSpecialization cti |
      cti.getPrimaryTemplate() instanceof IsLiteralTypeTemplate and
      usage.(TypeMention).getMentionedType() = cti and
      type = "std::is_literal_type" and
      useKind = "specialization"
    )
    or
    exists(VariableTemplateSpecialization vts |
      vts.getPrimaryTemplate() instanceof IsLiteralTypeVariable and
      usage.(VariableAccess).getTarget() = vts and
      type = "std::is_literal_type" and
      useKind = "specialization"
    )
  )
select usage, "Use of deprecated type trait '" + type + "' through " + useKind + "."
