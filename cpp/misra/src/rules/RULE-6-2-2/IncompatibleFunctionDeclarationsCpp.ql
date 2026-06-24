/**
 * @id cpp/misra/incompatible-function-declarations-cpp
 * @name RULE-6-2-2: Do not create incompatible declarations of the same function or object
 * @description Declaring incompatible functions, in other words same named function of different
 *              return types or with different numbers of parameters or parameter types, then
 *              accessing those functions can lead to undefined behaviour.
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
import codingstandards.cpp.rules.incompatiblefunctiondeclaration.IncompatibleFunctionDeclaration

module IncompatibleFunctionDeclarationsCppConfig implements IncompatibleFunctionDeclarationConfigSig
{
  Query getQuery() { result = Declarations2Package::incompatibleFunctionDeclarationsCppQuery() }
}

import IncompatibleFunctionDeclaration<IncompatibleFunctionDeclarationsCppConfig>
