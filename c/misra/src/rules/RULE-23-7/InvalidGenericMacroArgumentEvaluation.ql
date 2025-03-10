/**
 * @id c/misra/invalid-generic-macro-argument-evaluation
 * @name RULE-23-7: A generic selection that is expanded from a macro should evaluate its argument only once
 * @description A generic selection that is expanded from a macro should evaluate its argument only
 *              once.
 * @kind problem
 * @precision medium
 * @problem.severity warning
 * @tags external/misra/id/rule-23-7
 *       correctness
 *       maintainability
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Generic

predicate allowedByException(string parameter, ParsedGenericMacro genericMacro) {
  genericMacro.expansionsOutsideExpr(parameter) = 0 and
  not genericMacro.expansionsInsideAssociation(parameter, _) > 0 and
  forall(MacroInvocation mi, C11GenericExpr expr |
    mi.getMacro() = genericMacro and
    mi.getAGeneratedElement() = expr
  |
    forall(Expr assoc | assoc = expr.getAnAssociationExpr() | exists(assoc.getValue()))
  )
}

from ParsedGenericMacro genericMacro, string parameter, string reason
where
  not isExcluded(genericMacro, GenericsPackage::invalidGenericMacroArgumentEvaluationQuery()) and
  parameter = genericMacro.getAParameter() and
  genericMacro.expansionsInsideControllingExpr(parameter) > 0 and
  (
    genericMacro.expansionsOutsideExpr(parameter) > 1 and
    reason = "expanded multiple times outside the generic selection"
    or
    genericMacro.expansionsOutsideExpr(parameter) = 1 and
    genericMacro.expansionsInsideAssociation(parameter, _) > 0 and
    reason = "expanded outside the generic selection and inside the generic selection"
    or
    genericMacro.expansionsOutsideExpr(parameter) = 0 and
    exists(int i |
      genericMacro.expansionsInsideAssociation(parameter, i) > 1 and
      reason = "expanded in generic selection " + i.toString() + " more than once"
    )
    or
    genericMacro.expansionsOutsideExpr(parameter) = 0 and
    exists(int i |
      genericMacro.expansionsInsideAssociation(parameter, i) = 0 and
      reason = "not expanded in generic selection " + i.toString()
    ) and
    not allowedByException(parameter, genericMacro)
  ) and
  not genericMacro.getBody().matches(["%sizeof%", "%__alignof%", "%typeof%", "%offsetof%"])
select genericMacro,
  "Generic macro " + genericMacro.getName() + " may have unexpected behavior from side effects " +
    "in parameter " + parameter + ", as it is " + reason + "."
