/**
 * @id cpp/cert/unnamed-namespace-in-header-file
 * @name DCL59-CPP: Do not define an unnamed namespace in a header file
 * @description Each translation unit has unique instances of members declared in an unnamed
 *              namespace leading to unexpected results, bloated executables, or undefined behavior
 *              due to one-definition rule violations if an unnamed namespace is introduced into
 *              translation units through a header file.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl59-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

from Namespace anonymousNamespace, HeaderFile headerFile
where
  not isExcluded(anonymousNamespace, ScopePackage::unnamedNamespaceInHeaderFileQuery()) and
  anonymousNamespace.isAnonymous() and
  anonymousNamespace.getFile() = headerFile
select anonymousNamespace, "Unnamed namespace is defined in the header file $@", headerFile,
  headerFile.getBaseName()
