/**
 * @id c/misra/repeated-initialization-of-aggregate-object-element
 * @name RULE-9-4: An element of an object shall not be initialized more than once
 * @description Repeated initialization of an element in an object can lead to side-effects or may
 *              signal a logic error.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-9-4
 *       correctness
 *       maintainability
 *       readability
 *       external/misra/c/2012/third-edition-first-revision
 *       coding-standards/baseline/safety
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.enhancements.AggregateLiteralEnhancements

/**
 * Gets the `n`th parent of `e`.
 * If `n` is zero, the result is `e`.
 */
Expr getNthParent(Expr e, int n) {
  if n = 0 then result = e else result = getNthParent(e.getParent(), n - 1)
}

/**
 * Returns a string representation of the index of `e` relative
 * to the nested array aggregate literal structure it is contained in.
 */
string getNestedArrayIndexString(Expr e) {
  result =
    concat(int depth |
      depth = [0 .. getMaxDepth(getRootAggregate(e.getParent()))]
    |
      "[" +
          any(int elementIndex |
            exists(ArrayAggregateLiteral parent |
              parent = getNthParent(e, pragma[only_bind_into](depth + 1)) and
              parent.getAnElementExpr(elementIndex) = getNthParent(e, pragma[only_bind_into](depth))
            )
          |
            elementIndex
          ).toString() + "]"
      order by
        depth desc
    )
}

/**
 * Returns the number of levels of nested `ArrayAggregateLiteral`s in `al`.
 * If there are no nested array aggregate literals, the max depth of the `ArrayAggregateLiteral` is `0`.
 */
language[monotonicAggregates]
int getMaxDepth(ArrayAggregateLiteral al) {
  if not exists(al.getAnElementExpr(_).(ArrayAggregateLiteral))
  then result = 0
  else result = 1 + max(Expr child | child = al.getAnElementExpr(_) | getMaxDepth(child))
}

// internal recursive predicate for `hasMultipleInitializerExprsForSameIndex`
predicate hasMultipleInitializerExprsForSameIndexInternal(
  ArrayAggregateLiteral root, Expr e1, Expr e2
) {
  root = e1 and root = e2
  or
  exists(ArrayAggregateLiteral parent1, ArrayAggregateLiteral parent2, int shared_index |
    hasMultipleInitializerExprsForSameIndexInternal(root, parent1, parent2) and
    shared_index = [0 .. parent1.getArraySize() - 1] and
    e1 = parent1.getAnElementExpr(shared_index) and
    e2 = parent2.getAnElementExpr(shared_index)
  )
}

/**
 * Holds if `expr1` and `expr2` both initialize the same array element of `root`.
 */
predicate hasMultipleInitializerExprsForSameIndex(ArrayAggregateLiteral root, Expr expr1, Expr expr2) {
  hasMultipleInitializerExprsForSameIndexInternal(root, expr1, expr2) and
  not root = expr1 and
  not root = expr2 and
  not expr1 = expr2 and
  (
    not expr1 instanceof ArrayAggregateLiteral
    or
    not expr2 instanceof ArrayAggregateLiteral
  )
}

/**
 * Holds if `expr1` and `expr2` both initialize the same field of `root`.
 *
 * The dbschema keyset for `aggregate_field_init` prevents referencing multiple `Expr`
 * that initialize the same Field and are part of the same `ClassAggregateLiteral`.
 * This predicate is therefore unable to distinguish the individual duplicate expressions.
 */
predicate hasMultipleInitializerExprsForSameField(ClassAggregateLiteral root, Field f) {
  count(root.getAFieldExpr(f)) > 1
}

from
  AggregateLiteral root, Expr e1, Expr e2, string elementDescription, string rootType,
  string clarification
where
  not isExcluded(e1, Memory1Package::repeatedInitializationOfAggregateObjectElementQuery()) and
  exists(Initializer init | init.getExpr() = root) and
  (
    hasMultipleInitializerExprsForSameIndex(root, e1, e2) and
    elementDescription = getNestedArrayIndexString(e1) and
    rootType = "Array aggregate literal" and
    clarification = ", which is already initialized $@."
    or
    exists(Field f |
      // we cannot distinguish between different aggregate field init expressions.
      // therefore, we only report the root aggregate rather than any child init expr.
      // see `hasMultipleInitializerExprsForSameField` documentation.
      hasMultipleInitializerExprsForSameField(root, f) and
      e1 = root and
      e2 = root and
      elementDescription = f.getQualifiedName() and
      rootType = "Structure aggregate literal" and
      clarification = "."
    )
  ) and
  // de-duplicate the results by excluding permutations of `e1` and `e2`
  e1.getLocation().toString() <= e2.getLocation().toString()
select e1, "$@ repeats initialization of element " + elementDescription + clarification, root,
  rootType, e2, "here"
