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
