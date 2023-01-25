/**
 * @id c/misra/memcmp-arg-not-pts-to-signed-unsigned-boolean-enum-ess-type
 * @name RULE-21-16: The pointer arguments to the Standard Library function memcmp shall point to either a pointer type,
 * @description The pointer arguments to the Standard Library function memcmp shall point to either
 *              a pointer type, an essentially signed type, an essentially unsigned type, an
 *              essentially Boolean type or an essentially enum type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-16
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::memcmpArgNotPtsToSignedUnsignedBooleanEnumEssTypeQuery()) and
select
