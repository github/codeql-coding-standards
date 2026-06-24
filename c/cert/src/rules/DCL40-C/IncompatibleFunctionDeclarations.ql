/**
 * @id c/cert/incompatible-function-declarations
 * @name DCL40-C: Do not create incompatible declarations of the same function or object
 * @description Declaring incompatible functions, in other words same named function of different
 *              return types or with different numbers of parameters or parameter types, then
 *              accessing those functions can lead to undefined behaviour.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/dcl40-c
 *       correctness
 *       maintainability
 *       readability
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.incompatiblefunctiondeclaration.IncompatibleFunctionDeclaration

module IncompatibleFunctionDeclarationsCppConfig implements IncompatibleFunctionDeclarationConfigSig
{
  Query getQuery() { result = Declarations2Package::incompatibleFunctionDeclarationsQuery() }
}

import IncompatibleFunctionDeclaration<IncompatibleFunctionDeclarationsCppConfig>
