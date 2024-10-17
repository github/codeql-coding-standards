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
import codingstandards.cpp.lifetimes.CLifetimes

/**
 * Get the expression(s) whose value is "used" by this expression.
 *
 * For instance, `(x)` does not use any values, but `x + y` uses `x` and `y`.
 *
 * A pointer-to-array conversion does not need to be flagged if the result of
 * that conversion is not used or stored.
 */
Expr usedValuesOf(Expr expr) {
  result = expr.(BinaryOperation).getLeftOperand()
  or
  result = expr.(BinaryOperation).getRightOperand()
  or
  result = expr.(UnaryOperation).getOperand()
  or
  result = expr.(ConditionalExpr).getCondition()
  or
  result = expr.(Call).getAnArgument()
}

/**
 * Get the expression(s) whose value is stored by this declaration.
 *
 * A pointer-to-array conversion does not need to be flagged if the result of
 * that conversion is not used or stored.
 */
predicate isStored(Expr e) {
  e = any(VariableDeclarationEntry d).getDeclaration().getInitializer().getExpr()
  or
  e = any(ClassAggregateLiteral l).getAFieldExpr(_)
}

/**
 * Find expressions that defer their value directly to an inner expression
 * value.
 *
 * When an array is on the rhs of a comma expr, or in the then/else branch of a
 * ternary expr, and the result us used as a pointer, then the ArrayToPointer
 * conversion is marked inside comma expr/ternary expr, on the operands. These
 * conversions are only non-compliant if they flow into an operation or store.
 *
 * Full flow analysis with localFlowStep should not be necessary, and may cast a
 * wider net than needed for some queries, potentially resulting in false
 * positives.
 */
Expr temporaryObjectFlowStep(Expr e) {
  e = result.(CommaExpr).getRightOperand()
  or
  e = result.(ConditionalExpr).getThen()
  or
  e = result.(ConditionalExpr).getElse()
}

from
  TemporaryLifetimeArrayAccess fa, TemporaryLifetimeExpr temporary,
  ArrayToPointerConversion conversion
where
  not isExcluded(conversion, InvalidMemory3Package::arrayToPointerConversionOfTemporaryObjectQuery()) and
  fa.getTemporary() = temporary and
  conversion.getExpr() = fa and
  (
    temporaryObjectFlowStep*(conversion.getExpr()) = usedValuesOf(any(Expr e))
    or
    isStored(temporaryObjectFlowStep*(conversion.getExpr()))
  )
select conversion, "Array to pointer conversion of array $@ from temporary object $@",
  fa.getTarget(), fa.getTarget().getName(), temporary, temporary.toString()
