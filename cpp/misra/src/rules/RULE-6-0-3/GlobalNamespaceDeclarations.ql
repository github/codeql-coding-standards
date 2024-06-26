/**
 * @id cpp/misra/global-namespace-declarations
 * @name RULE-6-0-3: The only declarations in the global namespace should be main, namespace declarations and extern "C"
 * @description The only declarations in the global namespace should be main, namespace declarations
 *              and extern "C" declarations.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-6-0-3
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.globalnamespacedeclarations_shared.GlobalNamespaceDeclarations_shared

class GlobalNamespaceDeclarationsQuery extends GlobalNamespaceDeclarations_sharedSharedQuery {
  GlobalNamespaceDeclarationsQuery() {
    this = ImportMisra23Package::globalNamespaceDeclarationsQuery()
  }
}
