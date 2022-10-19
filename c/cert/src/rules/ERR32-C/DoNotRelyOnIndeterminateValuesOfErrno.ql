/**
 * @id c/cert/do-not-rely-on-indeterminate-values-of-errno
 * @name ERR32-C: Do not rely on indeterminate values of errno
 * @description Do not rely on indeterminate values of errno.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err32-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, Contracts4Package::doNotRelyOnIndeterminateValuesOfErrnoQuery()) and
select
