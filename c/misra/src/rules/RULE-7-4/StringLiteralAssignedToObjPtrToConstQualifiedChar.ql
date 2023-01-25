/**
 * @id c/misra/string-literal-assigned-to-obj-ptr-to-const-qualified-char
 * @name RULE-7-4: A string literal shall not be assigned to an object unless the object's type is 'pointer to
 * @description A string literal shall not be assigned to an object unless the object's type is
 *              'pointer to const-qualified char'.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-7-4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::stringLiteralAssignedToObjPtrToConstQualifiedCharQuery()) and
select
