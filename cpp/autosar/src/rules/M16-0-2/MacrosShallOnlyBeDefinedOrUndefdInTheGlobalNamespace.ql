/**
 * @id cpp/autosar/macros-shall-only-be-defined-or-undefd-in-the-global-namespace
 * @name M16-0-2: Macros shall only be #define'd or #undef'd in the global namespace
 * @description Macros have unrestricted scope, therefore defining them in anything other than
 *              global namespace can make the code confusing to read.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-2
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isLocatedInNamespaceBody(NamespaceDeclarationEntry n, PreprocessorDirective m) {
  m.getFile() = n.getFile() and
  m.getLocation().getStartLine() >= n.getBodyLocation().getStartLine() and
  m.getLocation().getEndLine() <= n.getBodyLocation().getEndLine()
}

from NamespaceDeclarationEntry n, PreprocessorDirective m, string def
where
  not n.getNamespace() instanceof GlobalNamespace and
  isLocatedInNamespaceBody(n, m) and
  (
    m instanceof Macro and
    def = "defined"
    or
    m instanceof PreprocessorUndef and
    def = "undefined"
  ) and
  not isExcluded(m, MacrosPackage::macrosShallOnlyBeDefinedOrUndefdInTheGlobalNamespaceQuery())
select m, "Macro " + m.getHead() + " " + def + " in a non-global namespace $@.", n,
  n.getNamespace().getName()
