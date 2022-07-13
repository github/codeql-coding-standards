/**
 * @id cpp/autosar/use-init-braces-to-match-type-structure
 * @name M8-5-2: Braces shall be used to indicate and match the structure in the non-zero initialization of arrays and structures
 * @description It can be confusing to the developer if the structure of braces in an initializer
 *              does not match the structure of the object being initialized.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/autosar/id/m8-5-2
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.enhancements.AggregateLiteralEnhancements

from
  InferredAggregateLiteral inferredAggregateLiteral, Type aggType, string parentDescription,
  Element explanationElement, string explanationDescription
where
  not isExcluded(inferredAggregateLiteral,
    InitializationPackage::useInitBracesToMatchTypeStructureQuery()) and
  // Not an inferred aggregate literal that acts as a "leading zero" for the root aggregate
  // e.g.
  // ```
  // int i[2][4] { 0 }
  // ```
  // Has an inferred aggregate literal (i.e. it's `{ { 0 } }`), but we shouldn't report it
  not isLeadingZeroInitialized(getRootAggregate(inferredAggregateLiteral)) and
  // Provide a good message, dependending on the type of the parent
  (
    // For class aggergate literal parents, report which field is being assigned to
    exists(ClassAggregateLiteral cal, Field field |
      cal.getFieldExpr(field) = inferredAggregateLiteral and
      parentDescription = "to field $@" and
      explanationElement = field
    |
      explanationDescription = field.getName()
    )
    or
    // For array aggregate literal parents, report which index is being assigned to
    exists(ArrayAggregateLiteral aal, int elementIndex |
      aal.getElementExpr(elementIndex) = inferredAggregateLiteral and
      parentDescription = "to index " + elementIndex + " in $@" and
      explanationElement = aal and
      explanationDescription = "array of type " + aal.getType().getName()
    )
    or
    // In some cases, we seem to have missing link, so provide a basic message
    not any(ArrayAggregateLiteral aal).getElementExpr(_) = inferredAggregateLiteral and
    not any(ClassAggregateLiteral aal).getFieldExpr(_) = inferredAggregateLiteral and
    parentDescription = "to an unnamed field of $@" and
    explanationElement = inferredAggregateLiteral.getParent() and
    explanationDescription = " " + explanationElement.(Expr).getType().getName()
  )
select inferredAggregateLiteral,
  "Missing braces on aggregate literal of " +
    getAggregateTypeDescription(inferredAggregateLiteral, aggType) + " which is assigned " +
    parentDescription + ".", aggType, aggType.getName(), explanationElement, explanationDescription
