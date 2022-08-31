/**
 * @id cpp/autosar/using-declarations-used-in-header-files
 * @name M7-3-6: Using-directives and using-declarations shall not be used in header files
 * @description Using-directives and using-declarations (excluding class scope or function scope
 *              using-declarations) shall not be used in header files.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/m7-3-6
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isInHeaderFile(UsingEntry u) { u.getFile() instanceof HeaderFile }

predicate isInFunctionScope(UsingEntry u) {
  exists(Function f | u.getParentScope().(BlockStmt).getEnclosingFunction() = f)
}

predicate isInClassScope(UsingEntry u) { exists(Class c | u.getEnclosingElement() = c) }

from UsingEntry u
where
  not isExcluded(u, BannedSyntaxPackage::usingDeclarationsUsedInHeaderFilesQuery()) and
  (isInHeaderFile(u) and not isInFunctionScope(u) and not isInClassScope(u))
select u, "Using directive or declaration used in a header file " + u.getFile() + "."
