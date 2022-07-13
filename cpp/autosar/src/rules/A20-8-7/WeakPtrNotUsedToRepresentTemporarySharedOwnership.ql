/**
 * @id cpp/autosar/weak-ptr-not-used-to-represent-temporary-shared-ownership
 * @name A20-8-7: A std::weak_ptr shall be used to represent temporary shared ownership
 * @description To avoid cyclical dependency of shared pointers, an std::weak_ptr shall be used to
 *              represent temporary shared ownership.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/autosar/id/a20-8-7
 *       correctness
 *       external/autosar/audit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers

Class baseAndDerivedClasses(Class c) {
  result = c.getABaseClass*() or
  result = c.getADerivedClass*()
}

private predicate indirectlyInstantiatesViaSharedPtr(Class sp_owner, Class sp_type) {
  // transitive derivations
  baseAndDerivedClasses(sp_type) = sp_owner
  or
  // either member variables defining an instance of a class or a shared_ptr
  // ignore raw pointers and references, as they do not result in an instantiation
  exists(MemberVariable mv, Type mvt, Class mvc |
    mv.getDeclaringType() = baseAndDerivedClasses(sp_type) and
    mv.getType() = mvt and
    not mvt instanceof ReferenceType and
    not mvt instanceof PointerType and
    mvc = mv.getType().stripType() and
    (
      // recurse over non std::shared_ptr objects
      not mvc instanceof AutosarSharedPointer and
      indirectlyInstantiatesViaSharedPtr(sp_owner, mvc)
      or
      // recurse over std::shared_ptr objects as they are capable of creating nested cycles
      indirectlyInstantiatesViaSharedPtr(sp_owner,
        mvc.(AutosarSharedPointer).getOwnedObjectType().(Class).getABaseClass*())
    )
  )
}

from MemberVariable sp, Class sp_owner, Class sp_type
where
  not isExcluded(sp, SmartPointers2Package::weakPtrNotUsedToRepresentTemporarySharedOwnershipQuery()) and
  sp_owner = sp.getDeclaringType() and
  sp_type = sp.getType().(AutosarSharedPointer).getOwnedObjectType() and
  // For performance, we avoid full transitive closure over `getDeclaringType`.
  // An ideal implementation would then manually recurse over additional declaring types,
  // but this implementation is a good performance trade-off and should cover most real-world cases.
  if sp_owner.hasDeclaringType()
  then indirectlyInstantiatesViaSharedPtr(sp_owner.getDeclaringType().getABaseClass*(), sp_type)
  else indirectlyInstantiatesViaSharedPtr(sp_owner.getABaseClass*(), sp_type)
select sp,
  "[AUDIT] Shared pointer `" + sp.getName() +
    "` may create a circular lifetime dependency in the inheritance hierarchies of $@ and $@.",
  sp_owner, sp_owner.getName(), sp_type, sp_type.getName()
