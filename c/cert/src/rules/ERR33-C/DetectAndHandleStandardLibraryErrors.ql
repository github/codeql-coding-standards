/**
 * @id c/cert/detect-and-handle-standard-library-errors
 * @name ERR33-C: Detect and handle standard library errors
 * @description Detect and handle standard library errors.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err33-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, Contracts4Package::detectAndHandleStandardLibraryErrorsQuery()) and
select
