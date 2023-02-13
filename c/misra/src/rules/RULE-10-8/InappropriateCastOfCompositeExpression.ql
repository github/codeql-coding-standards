/**
 * @id c/misra/inappropriate-cast-of-composite-expression
 * @name RULE-10-8: The value of a composite expression shall not be cast to a different essential type category or a
 * @description The value of a composite expression shall not be cast to a different essential type
 *              category or a wider essential type
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-10-8
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import codingstandards.c.misra.MisraExpressions

from
  Cast c, CompositeExpression ce, Type castEssentialType, Type compositeExprEssentialType,
  EssentialTypeCategory castTypeCategory, EssentialTypeCategory compositeTypeCategory,
  string message
where
  not isExcluded(ce, EssentialTypesPackage::inappropriateCastOfCompositeExpressionQuery()) and
  c = ce.getExplicitlyConverted() and
  compositeExprEssentialType = getEssentialTypeBeforeConversions(ce) and
  castEssentialType = c.getType() and
  castTypeCategory = getEssentialTypeCategory(castEssentialType) and
  compositeTypeCategory = getEssentialTypeCategory(compositeExprEssentialType) and
  (
    not castTypeCategory = compositeTypeCategory and
    message =
      "Cast from " + compositeTypeCategory + " to " + castTypeCategory + " changes type category."
    or
    castTypeCategory = compositeTypeCategory and
    castEssentialType.getSize() > compositeExprEssentialType.getSize() and
    message = "Cast from " + compositeTypeCategory + " to " + castTypeCategory + " widens type."
  )
select ce, message
