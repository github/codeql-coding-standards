/**
 * @id c/misra/typedefs-that-indicate-size-and-sig
 * @name DIR-4-6: typedefs that indicate size and signedness should be used in place of the basic numerical types
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/dir-4-6
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::typedefsThatIndicateSizeAndSigQuery()) and
select
