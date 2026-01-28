/**
 * @id cpp/misra/internal-linkage-specified-appropriately
 * @name RULE-6-5-2: Internal linkage should be specified appropriately
 * @description Using certain specifiers or declaring entities with internal linkage in certain
 *              namespaces can lead to confusion as to the linkage of the entity and can cause code
 *              to be more difficult to read.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-5-2
 *       correctness
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.Linkage
import codingstandards.cpp.types.Pointers

from DeclarationEntry decl, string message
where
  not isExcluded(decl, Linkage2Package::internalLinkageSpecifiedAppropriatelyQuery()) and
  hasInternalLinkage(decl.getDeclaration()) and
  //exclusions as per rule for const and constexpr Variables
  not decl.getDeclaration().(Variable).getUnderlyingType().isConst() and
  not decl.getDeclaration().(Variable).getType().(PointerOrArrayType).isDeeplyConstBelow() and
  not decl.getDeclaration().(Variable).isConstexpr() and
  (
    decl.hasSpecifier("static") and
    (
      decl.getDeclaration().getNamespace().isAnonymous() and
      message = "Static specifier used in anonymous namespace."
      or
      not decl.getDeclaration().getNamespace().isAnonymous() and
      message = "Static specifier used in non-anonymous namespace."
    )
    or
    decl.hasSpecifier("extern") and
    decl.getDeclaration().getNamespace().isAnonymous() and
    message = "Extern specifier used in anonymous namespace."
  )
select decl, message
