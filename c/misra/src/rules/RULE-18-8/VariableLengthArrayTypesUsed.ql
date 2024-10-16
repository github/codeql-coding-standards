/**
 * @id c/misra/variable-length-array-types-used
 * @name RULE-18-8: Variable-length array types shall not be used
 * @description Using a variable length array can lead to unexpected or undefined program behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-8
 *       correctness
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra

from VlaDeclStmt v, Expr size, ArrayType arrayType, string typeStr
where
  not isExcluded(v, Declarations7Package::variableLengthArrayTypesUsedQuery()) and
  size = v.getVlaDimensionStmt(0).getDimensionExpr() and
  (
    arrayType = v.getVariable().getType()
    or
    arrayType = v.getType().getUnspecifiedType()
  ) and
  typeStr = arrayType.getBaseType().toString()
select v, "Variable length array of element type '" + typeStr + "' with non-constant size $@.",
  size, size.toString()
