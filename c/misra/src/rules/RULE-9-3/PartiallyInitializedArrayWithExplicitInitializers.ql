/**
 * @id c/misra/partially-initialized-array-with-explicit-initializers
 * @name RULE-9-3: Arrays shall not be partially initialized
 * @description An array object or a subobject of an array shall be explicitly initialized if any
 *              other object in that array is explicitly initialized.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-9-3
 *       maintainability
 *       readability
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.enhancements.AggregateLiteralEnhancements

/**
 * Holds if the aggregate literal has at least one explicit initializer, and at least one
 * _missing_ explicit initializer, and not _only_ designated initializers.
 */
predicate isMissingExplicitInitializers(AggregateLiteral al) {
  not al.isCompilerGenerated() and
  not al.isAffectedByMacro() and
  // Partially initialized, but not initialized with a leading zero (which is permitted)
  isPartiallyValueInitialized(al) and
  not isLeadingZeroInitialized(al)
}

// note: this query is similar to M8-5-2: MissingExplicitInitializers.ql
// but, pursuant to Rule 9.3, only covers array initializers rather than all aggregates
from AggregateLiteral al, Type aggType, Element explanationElement, string explanationDescription
where
  not isExcluded(al, Memory1Package::partiallyInitializedArrayWithExplicitInitializersQuery()) and
  // The aggregate literal is missing at least one explicit initializer
  isMissingExplicitInitializers(al) and
  // Missing array initializer
  exists(int arraySize, int minIndex, int maxIndex |
    // Identify the size of the array with a missing initializer
    arraySize = al.getType().getUnspecifiedType().(ArrayType).getArraySize() and
    // Identify the smallest index missing an initialzer
    minIndex =
      min(int index |
        index = [0 .. arraySize - 1] and ArrayAggregateLiterals::isValueInitialized(al, index)
      |
        index
      ) and
    // Identify the largest index missing an initialzer
    maxIndex =
      max(int index |
        index = [0 .. arraySize - 1] and ArrayAggregateLiterals::isValueInitialized(al, index)
      |
        index
      ) and
    // Ensure that the maxIndex is the last array entry. If it's not, something is up with this
    // database, and so we shouldn't report it (because you can only initialize trailing array
    // values)
    maxIndex = (arraySize - 1) and
    // Nothing useful to point to as the explanation element, so let's just set it to the parent
    // array
    explanationElement = al and
    (
      if minIndex = maxIndex
      then
        // Only one element missing
        explanationDescription = "the element at index " + minIndex
      else
        // Multiple elements missing
        explanationDescription = "the elements in the index range " + minIndex + " to " + maxIndex
    )
  )
select al,
  "Aggregate literal for " + getAggregateTypeDescription(al, aggType) +
    " is missing an explicit initializer for $@.", aggType, aggType.getName(), explanationElement,
  explanationDescription
