/**
 * @id cpp/misra/unused-type-with-limited-visibility
 * @name RULE-0-2-3: Types with limited visibility should be used at least once
 * @description Types that are unused with limited visibility are unnecessary and should either be
 *              removed or may indicate a developer mistake.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-0-2-3
 *       scope/single-translation-unit
 *       maintainability
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.Uses

predicate hasLimitedVisibility(UserType type) {
  type.isLocal() or
  type.getNamespace().isAnonymous()
}

predicate hasMaybeUnusedAttribute(UserType type) {
  exists(Attribute a | a = type.getAnAttribute() and a.getName() = "maybe_unused")
}

from UserType type
where
  not isExcluded(type, DeadCode9Package::unusedTypeWithLimitedVisibilityQuery()) and
  hasLimitedVisibility(type) and
  not exists(getATypeUse(type)) and
  not hasMaybeUnusedAttribute(type) and
  not type instanceof TypeTemplateParameter and
  not type instanceof ClassTemplateSpecialization
select type, "Type '" + type.getName() + "' with limited visibility is not used."
