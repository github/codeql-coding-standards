/**
 * @id c/misra/sizeof-operator-used-on-array-type-param
 * @name RULE-12-5: The sizeof operator should not be used on an array type function parameter
 * @description Using sizeof operator on an array type function parameter leads to unintended
 *              results.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-5
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra

from SizeofExprOperator sizeof
where
  not isExcluded(sizeof, Types1Package::sizeofOperatorUsedOnArrayTypeParamQuery()) and
  exists(Parameter param |
    sizeof.getExprOperand().(VariableAccess).getTarget() = param and
    param.getType() instanceof ArrayType
  )
select sizeof,
  "The sizeof operator is called on an array-type parameter " + sizeof.getExprOperand() + "."
