/**
 * @id cpp/misra/incompatible-object-declarations-cpp
 * @name RULE-6-2-2: Do not create incompatible declarations of the same function or object
 * @description Declaring incompatible objects, in other words same named objects of different
 *              types, then accessing those objects can lead to undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-6-2-2
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.incompatibleobjectdeclaration.IncompatibleObjectDeclaration

module IncompatibleObjectDeclarationsCppConfig implements IncompatibleObjectDeclarationConfigSig {
  Query getQuery() { result = Declarations2Package::incompatibleObjectDeclarationsCppQuery() }
}

import IncompatibleObjectDeclaration<IncompatibleObjectDeclarationsCppConfig>
