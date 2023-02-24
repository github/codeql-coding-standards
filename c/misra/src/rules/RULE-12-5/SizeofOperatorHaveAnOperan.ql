/**
 * @id c/misra/sizeof-operator-have-an-operan
 * @name RULE-12-5: The sizeof operator shall not have an operand which is a function parameter declared as 'array of
 * @description The sizeof operator shall not have an operand which is a function parameter declared
 *              as 'array of type'.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-5
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::sizeofOperatorHaveAnOperanQuery()) and
select
