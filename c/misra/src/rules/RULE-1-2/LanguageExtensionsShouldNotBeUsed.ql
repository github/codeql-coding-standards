/**
 * @id c/misra/language-extensions-should-not-be-used
 * @name RULE-1-2: Language extensions should not be used
 * @description Language extensions are not portable to other compilers and should not be used.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-1-2
 *       maintainability
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Extensions

from CCompilerExtension e
where not isExcluded(e, Language3Package::languageExtensionsShouldNotBeUsedQuery())
select e, "Is a compiler extension and is not portable to other compilers."
