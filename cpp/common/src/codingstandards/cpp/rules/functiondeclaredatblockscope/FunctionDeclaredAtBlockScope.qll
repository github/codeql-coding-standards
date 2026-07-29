/**
 * Provides a configurable module FunctionDeclaredAtBlockScope with a `problems` predicate
 * for the following issue:
 * A function declared at block scope can make code harder to read and may lead to
 * developer confusion.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

signature module FunctionDeclaredAtBlockScopeConfigSig {
  Query getQuery();
}

module FunctionDeclaredAtBlockScope<FunctionDeclaredAtBlockScopeConfigSig Config> {
  query predicate problems(Function f, string message) {
    exists(DeclStmt decl |
      not isExcluded(decl, Config::getQuery()) and
      not isExcluded(f, Config::getQuery()) and
      decl.getADeclaration() = f and
      message = "Function " + f.getName() + " is declared at block scope."
    )
  }
}
