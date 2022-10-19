/**
 * @id c/misra/language-not-encapsulated-and-isolated
 * @name DIR-4-3: Assembly language shall be encapsulated and isolated
 * @description Failing to encapsulate assembly language limits the portability, reliability, and
 *              readability of programs.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/dir-4-3
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, Language1Package::languageNotEncapsulatedAndIsolatedQuery()) and
select
