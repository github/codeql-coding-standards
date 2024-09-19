/**
 * Provides a library with a `problems` predicate for the following issue:
 * A using declaration that makes a symbol available for unqualified lookup does not
 * included definitions defined after the using declaration which can result in
 * unexpected behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class DefinitionNotConsideredForUnqualifiedLookupSharedQuery extends Query { }

Query getQuery() { result instanceof DefinitionNotConsideredForUnqualifiedLookupSharedQuery }

/**
 * Holds if `functionDecl` is a possible intended target of the `usingDecl`.
 */
pragma[noinline]
predicate isPossibleIntendedTarget(
  FunctionDeclarationEntry functionDecl, UsingDeclarationEntry usingDecl
) {
  // Extracted to improve the join order. With this approach, we first compute a set of using
  // declarations and a set of possible intended targets
  functionDecl.getDeclaration().isTopLevel() and
  functionDecl.getDeclaration().getQualifiedName() = usingDecl.getDeclaration().getQualifiedName() and
  functionDecl.getDeclaration().getNamespace().getParentNamespace*() = usingDecl.getParentScope()
}

/**
 * Holds if `functionDecl` is a possible intended target of the `usingDecl`, and they exist at the
 * given locations.
 */
pragma[noinline]
predicate isPossibleIntendedTargetLocation(
  FunctionDeclarationEntry functionDecl, UsingDeclarationEntry usingDecl, File usingsFile,
  File unavailableFile, int usingsStartLine, int unavailableStartLine
) {
  // Extracted to improve the join order. With this approach, we take the set of possible intended
  // targets computed in isPossibleIntendedTargets, and compute the files and start lines.
  // This helps avoid the join order preferred by the optimiser if this is all written directly in
  // the from-where-select, where it will eagerly join:
  //
  // usingDeclarationEntries -> enclosing files -> all other elements in those files
  //
  // which is expensive when there are a lot of files with using declarations
  isPossibleIntendedTarget(functionDecl, usingDecl) and
  usingsFile = usingDecl.getFile() and
  unavailableFile = functionDecl.getFile() and
  usingsStartLine = usingDecl.getLocation().getStartLine() and
  unavailableStartLine = functionDecl.getLocation().getStartLine()
}

query predicate problems(
  FunctionDeclarationEntry unavailableDecl, string message, UsingDeclarationEntry usingDecl,
  string usingDecl_string
) {
  not isExcluded(unavailableDecl, getQuery()) and
  exists(File usingsFile, File unavailableFile, int usingsStartLine, int unavailableStartLine |
    isPossibleIntendedTargetLocation(unavailableDecl, usingDecl, usingsFile, unavailableFile,
      usingsStartLine, unavailableStartLine) and
    // An approximation of order where we want the using to preceed the new declaration.
    usingsFile = unavailableFile and
    usingsStartLine < unavailableStartLine
  ) and
  message =
    "Definition for '" + unavailableDecl.getName() +
      "' is not available for unqualified lookup because it is declared after $@" and
  usingDecl_string = "using-declaration"
}
