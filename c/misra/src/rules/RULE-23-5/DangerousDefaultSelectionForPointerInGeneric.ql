/**
 * @id c/misra/dangerous-default-selection-for-pointer-in-generic
 * @name RULE-23-5: A generic selection should not depend on implicit pointer type conversion
 * @description Pointer types in a generic selection do not undergo pointer conversions and should
 *              not counterintuitively fall through to the default association.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-23-5
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.AlertReporting
import codingstandards.cpp.types.Compatible
import codingstandards.cpp.types.LvalueConversion
import codingstandards.cpp.types.SimpleAssignment

predicate typesCompatible(Type t1, Type t2) {
  TypeEquivalence<TypesCompatibleConfig, relevantTypes/2>::equalTypes(t1, t2)
}

predicate relevantTypes(Type a, Type b) {
  exists(C11GenericExpr g |
    a = g.getAnAssociationType() and
    b = getLvalueConverted(g.getControllingExpr().getFullyConverted().getType())
  )
}

predicate missesOnPointerConversion(Type provided, Type expected) {
  // The provided type is not compatible with the expected type:
  not typesCompatible(provided, expected) and
  // But 6.5.16.1 simple assignment constraints would have been satisfied:
  (
    // Check as if the controlling expr is assigned to the expected type:
    SimpleAssignment<relevantTypes/2>::satisfiesSimplePointerAssignment(expected, provided)
    or
    // Since developers typically rely on the compiler to catch const/non-const assignment
    // errors, don't assume a const-to-non-const generic selection miss was intentional.
    SimpleAssignment<relevantTypes/2>::satisfiesSimplePointerAssignment(provided, expected)
  )
}

from
  C11GenericExpr generic, Expr controllingExpr, Type providedType, Type missedType,
  Type lvalueConverted, Element extraElement, string extraString, string extraElementName
where
  not isExcluded(generic, GenericsPackage::dangerousDefaultSelectionForPointerInGenericQuery()) and
  controllingExpr = generic.getControllingExpr() and
  providedType = generic.getControllingExpr().getFullyConverted().getType() and
  // The controlling expression undergoes lvalue conversion:
  lvalueConverted = getLvalueConverted(providedType) and
  // There is no perfect match
  not typesCompatible(lvalueConverted, generic.getAnAssociationType()) and
  // There is a default selector.
  exists(VoidType default | default = generic.getAnAssociationType()) and
  missedType = generic.getAnAssociationType() and
  missesOnPointerConversion(lvalueConverted, missedType) and
  extraElement = MacroUnwrapper<C11GenericExpr>::unwrapElement(generic) and
  (
    if extraElement instanceof Macro
    then (
      extraString = " in generic macro $@" and extraElementName = extraElement.(Macro).getName()
    ) else (
      extraString = "" and extraElementName = ""
    )
  )
select generic,
  "Generic matched default selection, as controlling argument type " + lvalueConverted.toString() +
    " does not undergo pointer conversion to " + missedType.toString() + extraString + ".",
  extraElement, extraElementName
