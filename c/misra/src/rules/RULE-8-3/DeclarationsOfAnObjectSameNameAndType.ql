/**
 * @id c/misra/declarations-of-an-object-same-name-and-type
 * @name RULE-8-3: All declarations of an object shall use the same names and type qualifiers
 * @description Using different types across the same declarations disallows strong type checking
 *              and can lead to undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-3
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Compatible

from VariableDeclarationEntry decl1, VariableDeclarationEntry decl2
where
  not isExcluded(decl1, Declarations4Package::declarationsOfAnObjectSameNameAndTypeQuery()) and
  not isExcluded(decl2, Declarations4Package::declarationsOfAnObjectSameNameAndTypeQuery()) and
  not decl1 = decl2 and
  not decl1.getVariable().getDeclaringType().isAnonymous() and
  // Declarations are for the same qualified name
  // Note: decl1.getVariable() = decl2.getVariable() does not work for common cases where an aliased
  //       type is used.
  decl1.getVariable().getQualifiedName() = decl2.getVariable().getQualifiedName() and
  // As we use qualified name, require that they share a common link target to ensure they are
  // for the same object
  (
    decl1.getVariable().(GlobalVariable).getALinkTarget() =
      decl2.getVariable().(GlobalVariable).getALinkTarget()
    or
    decl1.getVariable().(Field).getDeclaringType().(Class).getALinkTarget() =
      decl2.getVariable().(Field).getDeclaringType().(Class).getALinkTarget()
  ) and
  not typesCompatible(decl1.getType(), decl2.getType())
select decl1,
  "The object $@ of type " + decl1.getType().toString() +
    " is not compatible with re-declaration $@ of type " + decl2.getType().toString(), decl1,
  decl1.getName(), decl2, decl2.getName()
