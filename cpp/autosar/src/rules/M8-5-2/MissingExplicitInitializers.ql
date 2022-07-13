/**
 * @id cpp/autosar/missing-explicit-initializers
 * @name M8-5-2: Non-zero initialization of arrays or structures requires an explicit initializer for each element
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

/**
 * Holds if the aggregate literal has at least one explicit initializer, and at least one
 * _missing_ explicit initializer.
 */
predicate isMissingExplicitInitializers(AggregateLiteral al) {
  not al.isCompilerGenerated() and
  not al.isAffectedByMacro() and
  // Ignore aggregates that are generated as part of Closures
  not getRootAggregate(al).getType() instanceof Closure and
  // Partially initialized, but not initialized with a leading zero (which is permitted)
  isPartiallyValueInitialized(al) and
  not isLeadingZeroInitialized(al)
}

from AggregateLiteral al, Type aggType, Element explanationElement, string explanationDescription
where
  not isExcluded(al, InitializationPackage::missingExplicitInitializersQuery()) and
  // The aggregate literal is missing at least one explicit initializer
  isMissingExplicitInitializers(al) and
  // Identify a missing element
  (
    // Missing field initializer
    exists(Field f |
      ClassAggregateLiterals::isValueInitialized(al, f) and
      explanationElement = f and
      explanationDescription = "field " + f.getName()
    )
    or
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
  )
select al,
  "Aggregate literal for " + getAggregateTypeDescription(al, aggType) +
    " is missing an explicit initializer for $@.", aggType, aggType.getName(), explanationElement,
  explanationDescription
