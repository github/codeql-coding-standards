/**
 * @id cpp/misra/polymorphic-class-type-expression-in-typeid
 * @name RULE-8-2-9: The operand to typeid shall not be an expression of polymorphic class type
 * @description It is unclear whether a typeid expression will be evaluated at runtime or compile
 *              time when its static type is a polymorphic class type.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-8-2-9
 *       scope/single-translation-unit
 *       readability
 *       correctness
 *       performance
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra

from TypeidOperator typeid, Expr operand, Class polymorphicClass
where
  not isExcluded(typeid, Preconditions1Package::polymorphicClassTypeExpressionInTypeidQuery()) and
  operand = typeid.getExpr().getFullyConverted() and
  polymorphicClass = operand.getType().getUnderlyingType() and
  polymorphicClass.isPolymorphic()
select typeid, "Use of 'typeid' with $@ of polymorphic class type $@.", operand, "expression",
  polymorphicClass, polymorphicClass.getName()
