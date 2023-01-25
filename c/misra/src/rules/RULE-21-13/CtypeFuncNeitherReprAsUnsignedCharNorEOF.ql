/**
 * @id c/misra/ctype-func-neither-repr-as-unsigned-char-nor-eof
 * @name RULE-21-13: Any value passed to a function in <ctype.h> shall be representable as an unsigned char or be the
 * @description Any value passed to a function in <ctype.h> shall be representable as an unsigned
 *              char or be the value EOF.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-21-13
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::ctypeFuncNeitherReprAsUnsignedCharNorEOFQuery()) and
select
