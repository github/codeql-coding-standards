/**
 * @id c/cert/incompatible-object-declarations
 * @name DCL40-C: Do not create incompatible declarations of the same function or object
 * @description Declaring incompatible objects, in other words same named objects of different
 *              types, then accessing those objects can lead to undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/dcl40-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import ExternalIdentifiers

from VariableDeclarationEntry decl1, VariableDeclarationEntry decl2
where
  not isExcluded(decl1, Declarations2Package::incompatibleObjectDeclarationsQuery()) and
  not isExcluded(decl2, Declarations2Package::incompatibleObjectDeclarationsQuery()) and
  not decl1.getUnspecifiedType() = decl2.getUnspecifiedType() and
  decl1.getDeclaration() instanceof ExternalIdentifiers and
  decl2.getDeclaration() instanceof ExternalIdentifiers and
  decl1.getLocation().getStartLine() >= decl2.getLocation().getStartLine() and
  decl1.getVariable().getName() = decl2.getVariable().getName()
select decl1, "The object $@ is not compatible with re-declaration $@", decl1, decl1.getName(),
  decl2, decl2.getName()
