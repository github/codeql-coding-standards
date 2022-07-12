/**
 * @id c/misra/modification-of-function-parameter
 * @name RULE-17-8: A function parameter should not be modified
 * @description A function parameter behaves in the same manner as an object with automatic storage
 *              duration and the effects of modifying a parameter are not visible in the calling
 *              function.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-17-8
 *       correctness
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra

from Parameter p, VariableAccess va
where
  not isExcluded(va, SideEffects2Package::modificationOfFunctionParameterQuery()) and
  p.getAnAccess() = va and
  va.isModified()
select va, "The parameter $@ is modified.", p, p.getName()
