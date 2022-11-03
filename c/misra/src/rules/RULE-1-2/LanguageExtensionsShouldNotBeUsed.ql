/**
 * @id c/misra/language-extensions-should-not-be-used
 * @name RULE-1-2: Language extensions should not be used
 * @description Language extensions can have inconsistent behavior and should not be used.
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

from
where
  not isExcluded(x, Language2Package::languageExtensionsShouldNotBeUsedQuery()) and
select
