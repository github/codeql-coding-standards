/**
 * @id c/misra/language-extensions-should-be-minimized
 * @name DIR-1-2: Language extensions should be minimized
 * @description Language extensions are not portable to other compilers and their use should be
 *              minimized.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-1-2
 *       maintainability
 *       readability
 *       external/misra/c/2025
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.AlertReporting
import codingstandards.c.Extensions

from CCompilerExtension extension
where
  not isExcluded(MacroUnwrapper<CCompilerExtension>::unwrapElement(extension),
    Language3Package::languageExtensionsShouldBeMinimizedQuery())
select MacroUnwrapper<CCompilerExtension>::unwrapElement(extension), extension.getMessage()
