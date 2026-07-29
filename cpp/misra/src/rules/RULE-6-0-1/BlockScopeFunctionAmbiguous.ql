/**
 * @id cpp/misra/block-scope-function-ambiguous
 * @name RULE-6-0-1: Block scope declarations shall not be visually ambiguous
 * @description A function declared at block scope can make code harder to read and may lead to
 *              developer confusion.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-6-0-1
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.functiondeclaredatblockscope.FunctionDeclaredAtBlockScope

module BlockScopeFunctionAmbiguousConfig implements FunctionDeclaredAtBlockScopeConfigSig {
  Query getQuery() { result = Declarations3Package::blockScopeFunctionAmbiguousQuery() }
}

import FunctionDeclaredAtBlockScope<BlockScopeFunctionAmbiguousConfig>
