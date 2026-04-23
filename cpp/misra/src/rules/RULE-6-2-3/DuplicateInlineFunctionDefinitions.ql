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

class RelevantDeclaration extends FunctionDeclarationEntry {
  Function function;

  RelevantDeclaration() {
    isDefinition() and
    function = getDeclaration() and
    function.isInline()
  }

  string getQualifiedName() { result = function.getQualifiedName() }
}

predicate interestedInFunctions(FunctionDeclarationEntry f1, FunctionDeclarationEntry f2) {
  not f1 = f2 and
  exists(RelevantDeclaration d1, RelevantDeclaration d2 |
    f1 = d1 and
    f2 = d2 and
    d1.getQualifiedName() = d2.getQualifiedName() and
    not f1.getFile() = f2.getFile()
  )
}

module FunDeclEquiv =
  FunctionDeclarationTypeEquivalence<TypesCompatibleConfig, interestedInFunctions/2>;

from RelevantDeclaration d1, RelevantDeclaration d2
where
  not isExcluded([d1, d2], Declarations8Package::duplicateInlineFunctionDefinitionsQuery()) and
  interestedInFunctions(d1, d2) and
  FunDeclEquiv::equalParameterTypes(d1, d2) and
  d1.getFile().getAbsolutePath() < d2.getFile().getAbsolutePath()
select d1, "Inline function '" + d1.getName() + "' is implemented in multiple files: $@ and $@.",
  d1, d1.getFile().getBaseName(), d2, d2.getFile().getBaseName()
