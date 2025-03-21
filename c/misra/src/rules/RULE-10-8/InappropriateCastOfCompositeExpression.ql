/**
 * @id c/misra/inappropriate-cast-of-composite-expression
 * @name RULE-10-8: Composite expression explicitly casted to wider or different essential type
 * @description The value of a composite expression shall not be cast to a different essential type
 *              category or a wider essential type.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-10-8
 *       maintainability
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
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
    if
      not castTypeCategory = compositeTypeCategory and
      not (
        // Exception 2: Casts between real or complex floating types are allowed
        castTypeCategory = EssentiallyFloatingType(_) and
        compositeTypeCategory = EssentiallyFloatingType(_)
      )
    then
      message =
        "Cast from " + compositeTypeCategory + " to " + castTypeCategory + " changes type category."
    else (
      getEssentialSize(castEssentialType) > getEssentialSize(compositeExprEssentialType) and
      message = "Cast from " + compositeTypeCategory + " to " + castTypeCategory + " widens type."
    )
  )
select ce, message
