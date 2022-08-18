/**
 * @id cpp/autosar/declarations-of-an-object-shall-have-compatible-types
 * @name M3-2-1: All declarations of an object shall have compatible types
 * @description It is undefined behavior if the declarations of an object or function in two
 *              different translation units do not have compatible types. The easiest way of
 *              ensuring object or function types are compatible is to make the declarations
 *              identical.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m3-2-1
 *       correctness
 *       security
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Typehelpers

from VariableDeclarationEntry decl1, VariableDeclarationEntry decl2
where
  not isExcluded(decl1, DeclarationsPackage::declarationsOfAnObjectShallHaveCompatibleTypesQuery()) and
  not isExcluded(decl2, DeclarationsPackage::declarationsOfAnObjectShallHaveCompatibleTypesQuery()) and
  not areCompatible(decl1.getType(), decl2.getType()) and
  // Note that normally `VariableDeclarationEntry` includes parameters, which are not covered
  // by this query. We implicitly exclude them with the `getQualifiedName()` predicate.
  decl1.getVariable().getQualifiedName() = decl2.getVariable().getQualifiedName() and
  // The underlying Variable shouldn't be from a TemplateVariable or a template instantiation
  not exists(Variable v |
    v = decl1.getVariable()
    or
    v = decl2.getVariable()
  |
    v instanceof TemplateVariable
    or
    v.isFromTemplateInstantiation(_)
  )
select decl1,
  "The object $@ of type " + decl1.getType().toString() +
    " is not compatible with re-declaration $@ of type " + decl2.getType().toString(), decl1,
  decl1.getName(), decl2, decl2.getName()
