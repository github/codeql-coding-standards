/**
 * @id c/misra/implicit-conversion-of-composite-expression
 * @name RULE-10-7: Implicit conversion of composite expression operand to wider essential type
 * @description If a composite expression is used as one operand of an operator in which the usual
 *              arithmetic conversions are performed then the other operand shall not have wider
 *              essential type.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-7
 *       maintainability
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import codingstandards.c.misra.MisraExpressions

bindingset[essentialTypeLeft, essentialTypeRight]
pragma[inline_late]
predicate isSameEssentialTypeCategory(Type essentialTypeLeft, Type essentialTypeRight) {
  getEssentialTypeCategory(essentialTypeLeft) = getEssentialTypeCategory(essentialTypeRight)
  or
  // Complex and real floating types are considered interchangeable
  getEssentialTypeCategory(essentialTypeLeft) = EssentiallyFloatingType(_) and
  getEssentialTypeCategory(essentialTypeRight) = EssentiallyFloatingType(_)
}

from
  OperationWithUsualArithmeticConversions arith, CompositeExpression compositeOp, Expr otherOp,
  Type compositeEssentialType, Type otherOpEssentialType
where
  not isExcluded(arith, EssentialTypesPackage::implicitConversionOfCompositeExpressionQuery()) and
  arith.getAnOperand() = compositeOp and
  arith.getAnOperand() = otherOp and
  not otherOp = compositeOp and
  compositeEssentialType = getEssentialType(compositeOp) and
  otherOpEssentialType = getEssentialType(otherOp) and
  getEssentialSize(compositeEssentialType) < getEssentialSize(otherOpEssentialType) and
  // Operands of a different type category in an operation with the usual arithmetic conversions is
  // prohibited by Rule 10.4, so we only report cases here where the essential type categories are
  // the same
  isSameEssentialTypeCategory(compositeEssentialType, otherOpEssentialType)
select arith,
  "Implicit conversion of $@ from " + compositeEssentialType + " to " + otherOpEssentialType,
  compositeOp, "composite op"
