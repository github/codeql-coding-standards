/**
 * @id c/cert/incompatible-object-declarations
 * @name DCL40-C: Do not create incompatible declarations of the same function or object
 * @description Declaring incompatible objects, in other words same named objects of different
 *              types, then accessing those objects can lead to undefined behaviour.
 * @ kind problem
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
import codingstandards.cpp.rules.incompatibleobjectdeclaration.IncompatibleObjectDeclaration

module IncompatibleObjectDeclarationsCppConfig implements IncompatibleObjectDeclarationConfigSig {
  Query getQuery() { result = Declarations2Package::incompatibleObjectDeclarationsQuery() }
}

import IncompatibleObjectDeclaration<IncompatibleObjectDeclarationsCppConfig>
