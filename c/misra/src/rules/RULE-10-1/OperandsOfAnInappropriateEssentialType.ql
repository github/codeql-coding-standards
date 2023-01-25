/**
 * @id c/misra/operands-of-an-inappropriate-essential-type
 * @name RULE-10-1: Operands shall not be of an inappropriate essential type
 * @description TODO.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-10-1
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from
where
  not isExcluded(x, TypesPackage::operandsOfAnInappropriateEssentialTypeQuery()) and
select
