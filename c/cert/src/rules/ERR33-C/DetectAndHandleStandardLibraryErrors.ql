/**
 * @id c/cert/detect-and-handle-standard-library-errors
 * @name ERR33-C: Detect and handle standard library errors
 * @description 
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err33-c
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert

from
where
  not isExcluded(x, Contracts4Package::detectAndHandleStandardLibraryErrorsQuery()) and
select
