/**
 * Provides a library which includes a `problems` predicate for reporting initializers
 * with brace structures that do not match the structure of the object being initialized.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.enhancements.AggregateLiteralEnhancements

abstract class UseInitializerBracesToMatchAggregateTypeStructureSharedQuery extends Query { }

Query getQuery() { result instanceof UseInitializerBracesToMatchAggregateTypeStructureSharedQuery }

query predicate problems(
  InferredAggregateLiteral inferredAggregateLiteral, string message, Type aggType,
  string aggTypeName, Element explanationElement, string explanationDescription
) {
  not isExcluded(inferredAggregateLiteral, getQuery()) and
  // Not an inferred aggregate literal that acts as a "leading zero" for the root aggregate
  // e.g.
  // ```
  // int i[2][4] { 0 }
  // ```
  // Has an inferred aggregate literal (i.e. it's `{ { 0 } }`), but we shouldn't report it
  not isLeadingZeroInitialized(getRootAggregate(inferredAggregateLiteral)) and
  // Provide a good message, dependending on the type of the parent
  exists(string parentDescription |
    // For class aggergate literal parents, report which field is being assigned to
    exists(ClassAggregateLiteral cal, Field field |
      cal.getAFieldExpr(field) = inferredAggregateLiteral and
      parentDescription = "to field $@" and
      explanationElement = field
    |
      explanationDescription = field.getName()
    )
    or
    // For array aggregate literal parents, report which index is being assigned to
    exists(ArrayAggregateLiteral aal, int elementIndex |
      aal.getAnElementExpr(elementIndex) = inferredAggregateLiteral and
      parentDescription = "to index " + elementIndex + " in $@" and
      explanationElement = aal and
      explanationDescription = "array of type " + aal.getType().getName()
    )
    or
    // In some cases, we seem to have missing link, so provide a basic message
    not any(ArrayAggregateLiteral aal).getAnElementExpr(_) = inferredAggregateLiteral and
    not any(ClassAggregateLiteral aal).getAFieldExpr(_) = inferredAggregateLiteral and
    parentDescription = "to an unnamed field of $@" and
    explanationElement = inferredAggregateLiteral.getParent() and
    explanationDescription = " " + explanationElement.(Expr).getType().getName()
  |
    aggTypeName = aggType.getName() and
    message =
      "Missing braces on aggregate literal of " +
        getAggregateTypeDescription(inferredAggregateLiteral, aggType) + " which is assigned " +
        parentDescription + "."
  )
}
