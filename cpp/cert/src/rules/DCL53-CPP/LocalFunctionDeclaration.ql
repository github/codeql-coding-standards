/**
 * @id cpp/cert/local-function-declaration
 * @name DCL53-CPP: Declare functions in the global namespace or other namespace
 * @description Declaration of functions inside a function requires the use of ambiguous syntax that
 *              could lead to unintended behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/dcl53-cpp
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p2
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

class LocalUserFunctionDeclarationEntry extends FunctionDeclarationEntry {
  DeclStmt ds;

  LocalUserFunctionDeclarationEntry() { ds.getADeclarationEntry() = this }

  Function getEnclosingFunction() { result = ds.getEnclosingFunction() }
}

from LocalUserFunctionDeclarationEntry de, Function scope
where
  not isExcluded(de, ScopePackage::localFunctionDeclarationQuery()) and
  scope = de.getEnclosingFunction() and
  // Exclude definitions because they don't use ambiguous syntax.
  not de.isDefinition() and
  not de.isInMacroExpansion()
select de, "Function $@ declares local function " + de.getName() + ".", scope, scope.getName()
