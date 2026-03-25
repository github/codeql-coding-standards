/**
 * @id cpp/misra/unnamed-namespaces-in-header-files
 * @name RULE-10-3-1: There should be no unnamed namespaces in header files
 * @description Anonymous namespaces in header files create separate entities in each translation
 *              unit, which may not be consistent with developer expectations.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-3-1
 *       scope/single-translation-unit
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from NamespaceDeclarationEntry namespaceDeclarationEntry, HeaderFile headerFile
where
  not isExcluded(namespaceDeclarationEntry, Banned4Package::unnamedNamespacesInHeaderFilesQuery()) and
  namespaceDeclarationEntry.getNamespace().isAnonymous() and
  headerFile = namespaceDeclarationEntry.getFile()
select namespaceDeclarationEntry, "Anonymous namespace declared in header file $@.", headerFile,
  headerFile.getBaseName()
