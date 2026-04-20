/**
 * @id cpp/misra/duplicate-inline-function-definitions
 * @name RULE-6-2-3: The source code used to implement an entity shall appear only once
 * @description Implementing an entity in multiple source locations increases the risk of ODR
 *              violations and undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-2-3
 *       correctness
 *       maintainability
 *       scope/system
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.types.Compatible

predicate isInline(FunctionDeclarationEntry d) { d.getDeclaration().isInline() }

predicate interestedInFunctions(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  f1.isDefinition() and
  f2.isDefinition() and
  f1.getDeclaration().getQualifiedName() = f2.getDeclaration().getQualifiedName() and
  isInline(f1) and
  isInline(f2) and
  not f1.getFile() = f2.getFile()
}

module FunDeclEquiv =
  FunctionDeclarationTypeEquivalence<TypesCompatibleConfig, interestedInFunctions/2>;

from FunctionDeclarationEntry d1, FunctionDeclarationEntry d2, string namespace, string name
where
  not isExcluded([d1, d2], Declarations8Package::duplicateInlineFunctionDefinitionsQuery()) and
  interestedInFunctions(d1, d2) and
  FunDeclEquiv::equalParameterTypes(d1, d2) and
  d1.getDeclaration().hasQualifiedName(namespace, name) and
  d2.getDeclaration().hasQualifiedName(namespace, name) and
  d1.getFile().getAbsolutePath() < d2.getFile().getAbsolutePath()
select d1, "Inline function '" + d1.getName() + "' is implemented in multiple files: $@ and $@.",
  d1, d1.getFile().getBaseName(), d2, d2.getFile().getBaseName()
