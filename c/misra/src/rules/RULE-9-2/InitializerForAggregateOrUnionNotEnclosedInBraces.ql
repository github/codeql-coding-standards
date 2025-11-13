/**
 * @id c/misra/initializer-for-aggregate-or-union-not-enclosed-in-braces
 * @name RULE-9-2: The initializer for an aggregate or union shall be enclosed in braces
 * @description Using braces in initializers of objects and subobjects improves code readability and
 *              clarifies intent.
 * @kind problem
 * @precision high
 * @problem.severity recommendation
 * @tags external/misra/id/rule-9-2
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.useinitializerbracestomatchaggregatetypestructure.UseInitializerBracesToMatchAggregateTypeStructure

class InitializerForAggregateOrUnionNotEnclosedInBracesQuery extends UseInitializerBracesToMatchAggregateTypeStructureSharedQuery
{
  InitializerForAggregateOrUnionNotEnclosedInBracesQuery() {
    this = Memory1Package::initializerForAggregateOrUnionNotEnclosedInBracesQuery()
  }
}
