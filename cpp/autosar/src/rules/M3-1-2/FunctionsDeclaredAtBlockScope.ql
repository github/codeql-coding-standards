/**
 * @id cpp/autosar/functions-declared-at-block-scope
 * @name M3-1-2: Functions shall not be declared at block scope
 * @description A function declared at block scope will refer to a member of the enclosing
 *              namespace, and so the declaration should be explicitly placed at the namespace
 *              level.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m3-1-2
 *       correctness
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.functiondeclaredatblockscope.FunctionDeclaredAtBlockScope

module FunctionDeclaredAtBlockScopeConfig implements FunctionDeclaredAtBlockScopeConfigSig {
  Query getQuery() { result = DeclarationsPackage::functionsDeclaredAtBlockScopeQuery() }
}

import FunctionDeclaredAtBlockScope<FunctionDeclaredAtBlockScopeConfig>
