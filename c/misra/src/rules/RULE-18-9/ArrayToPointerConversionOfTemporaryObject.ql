/**
 * @id c/misra/array-to-pointer-conversion-of-temporary-object
 * @name RULE-18-9: An object with temporary lifetime shall not undergo array to pointer conversion
 * @description Modifying or accessing elements of an array with temporary lifetime that has been
 *              converted to a pointer will result in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-18-9
 *       external/misra/c/2012/amendment3
 *       correctness
 *       security
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Objects
import codingstandards.cpp.Expr

/**
 * Holds if the value of an expression is used or stored.
 *
 * For instance, `(x)` does not use any values, but `x + y` uses `x` and `y`.
 *
 * A pointer-to-array conversion does not need to be flagged if the result of
 * that conversion is not used or stored.
 */
predicate isUsedOrStored(Expr e) {
  e = any(Operation o).getAnOperand()
  or
  e = any(ConditionalExpr c).getCondition()
  or
  e = any(Call c).getAnArgument()
  or
  e = any(VariableDeclarationEntry d).getDeclaration().getInitializer().getExpr()
  or
  e = any(ClassAggregateLiteral l).getAFieldExpr(_)
}

from FieldAccess fa, TemporaryObjectIdentity temporary, ArrayToPointerConversion conversion
where
  not isExcluded(conversion, InvalidMemory3Package::arrayToPointerConversionOfTemporaryObjectQuery()) and
  fa = temporary.getASubobjectAccess() and
  conversion.getExpr() = fa and
  exists(Expr useOrStore |
    temporaryObjectFlowStep*(conversion.getExpr(), useOrStore) and
    isUsedOrStored(useOrStore)
  )
select conversion, "Array to pointer conversion of array $@ from temporary object $@.",
  fa.getTarget(), fa.getTarget().getName(), temporary, temporary.toString()
