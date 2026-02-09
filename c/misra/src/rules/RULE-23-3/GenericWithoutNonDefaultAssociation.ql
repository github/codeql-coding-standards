/**
 * @id c/misra/generic-without-non-default-association
 * @name RULE-23-3: A generic selection should contain at least one non-default association
 * @description A generic selection should contain at least one non-default association.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-23-3
 *       correctness
 *       maintainability
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.AlertReporting

class InvalidGeneric extends C11GenericExpr {
  InvalidGeneric() {
    not exists(Type t |
      t = getAnAssociationType() and
      not t instanceof VoidType
    )
  }
}

from InvalidGeneric generic, Element primaryElement
where
  not isExcluded(primaryElement, GenericsPackage::genericWithoutNonDefaultAssociationQuery()) and
  not exists(Type t |
    t = generic.getAnAssociationType() and
    not t instanceof VoidType
  ) and
  primaryElement = MacroUnwrapper<InvalidGeneric>::unwrapElement(generic)
select primaryElement, "Generic selection contains no non-default association."
