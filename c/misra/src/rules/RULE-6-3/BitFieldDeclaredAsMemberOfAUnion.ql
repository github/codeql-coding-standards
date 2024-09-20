/**
 * @id c/misra/bit-field-declared-as-member-of-a-union
 * @name RULE-6-3: A bit field shall not be declared as a member of a union
 * @description Type punning on a union with bit fields relies on implementation-specific alignment
 *              behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-6-3
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from BitField field, Union u
where
  not isExcluded(field, BitfieldTypes2Package::bitFieldDeclaredAsMemberOfAUnionQuery()) and
  u.getAField() = field
select
  field, "Union member " + field.getName() + " is declared as a bit field which relies on implementation-specific behavior."