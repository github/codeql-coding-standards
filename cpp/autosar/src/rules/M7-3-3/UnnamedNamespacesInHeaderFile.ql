/**
 * @id cpp/autosar/unnamed-namespaces-in-header-file
 * @name M7-3-3: There shall be no unnamed namespaces in header files
 * @description Unnamed namespaces are unique within each translation unit, which can be confusing
 *              for developers.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m7-3-3
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from NamespaceDeclarationEntry ns
where
  not isExcluded(ns, NamingPackage::unnamedNamespacesInHeaderFileQuery()) and
  ns.getNamespace().isAnonymous() and
  ns.fromSource() and
  ns.getFile() instanceof HeaderFile
select ns, "Unamed namespace in header file"
