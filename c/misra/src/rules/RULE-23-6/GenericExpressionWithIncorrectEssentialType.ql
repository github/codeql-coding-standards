/**
 * @id c/misra/generic-expression-with-incorrect-essential-type
 * @name RULE-23-6: The controlling expression of a generic selection shall have an essential type that matches its standard type
 * @description The controlling expression of a generic selection shall have an essential type that
 *              matches its standard type.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-23-6
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import codingstandards.cpp.Cpp14Literal
import codingstandards.cpp.AlertReporting

predicate allowedByException(Expr expr, Type essentialType) {
  // Constant expressions
  exists(expr.getValue()) and
  (
    // with essentially signed or unsigned type
    getEssentialTypeCategory(essentialType) = EssentiallySignedType()
    or
    getEssentialTypeCategory(essentialType) = EssentiallyUnsignedType()
  ) and
  // with lower rank than `int`
  essentialType.getSize() < any(IntType t).getSize() and
  // and not a character constant
  not expr instanceof Cpp14Literal::CharLiteral
}

from
  C11GenericExpr generic, Expr ctrlExpr, Type ctrlType, Type ctrlEssentialType,
  Element extraElement, string extraString, string extraMessage
where
  not isExcluded(ctrlExpr, GenericsPackage::genericExpressionWithIncorrectEssentialTypeQuery()) and
  ctrlExpr = generic.getControllingExpr() and
  ctrlType = ctrlExpr.getFullyConverted().getType() and
  ctrlEssentialType = getEssentialType(ctrlExpr) and
  // Exclude lvalue conversion on const structs
  exists(getEssentialTypeCategory(ctrlEssentialType)) and
  (
    not ctrlEssentialType = ctrlType
    or
    getEssentialTypeCategory(ctrlEssentialType) = EssentiallyEnumType()
  ) and
  not allowedByException(ctrlExpr, ctrlEssentialType) and
  extraElement = MacroUnwrapper<C11GenericExpr>::unwrapElement(generic) and
  (
    if extraElement instanceof Macro
    then (
      extraMessage = "macro $@ " and extraString = extraElement.(Macro).getName()
    ) else (
      extraMessage = "" and extraString = ""
    )
  )
select generic,
  "Controlling expression in generic " + extraMessage + "has standard type " + ctrlType.toString() +
    ", which doesn't match its essential type " + ctrlEssentialType.toString() + ".", extraElement,
  extraString
