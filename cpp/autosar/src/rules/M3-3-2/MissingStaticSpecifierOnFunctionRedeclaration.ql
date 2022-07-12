/**
 * @id cpp/autosar/missing-static-specifier-on-function-redeclaration
 * @name M3-3-2: If a function has internal linkage then all re-declarations shall include the static storage class
 * @description If a function has internal linkage then all re-declarations shall include the static
 *              storage class specifier to make the internal linkage explicit.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m3-3-2
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from FunctionDeclarationEntry fde, FunctionDeclarationEntry redeclaration
where
  not isExcluded(redeclaration) and
  fde.hasSpecifier("static") and
  fde.getDeclaration().isTopLevel() and
  redeclaration.getDeclaration() = fde.getDeclaration() and
  not redeclaration.hasSpecifier("static") and
  fde != redeclaration
select redeclaration, "The redeclaration of $@ with internal linkage misses the static specifier.",
  fde, "function"
