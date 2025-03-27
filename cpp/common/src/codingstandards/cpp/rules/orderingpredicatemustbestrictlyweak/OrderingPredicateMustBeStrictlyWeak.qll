/**
 *  Provides a query that checks to see if an ordering predicate is strictly
 *  weakly ordered. In addition to the checks this query performs, it also
 *  introduces an annotation `@IsStrictlyWeaklyOrdered` which allows a user to
 *  specify predicates that should be considered to follow this restriction
 *  because they have been hand validated by the user
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class OrderingPredicateMustBeStrictlyWeakSharedQuery extends Query { }

Query getQuery() { result instanceof OrderingPredicateMustBeStrictlyWeakSharedQuery }

class IsStrictlyWeaklyOrderedComment extends Comment {
  IsStrictlyWeaklyOrderedComment() {
    exists(getContents().regexpFind("(?m)^\\s*(//|\\*)\\s*@IsStrictlyWeaklyOrdered\\s*$", _, _))
  }
}

/**
 * User annotated class indicating a comparator is axiomatically strictly weakly
 * ordering.
 */
class UserDefinedStrictlyWeakOrderingComparator extends Class {
  UserDefinedStrictlyWeakOrderingComparator() {
    exists(IsStrictlyWeaklyOrderedComment c | c.getCommentedElement() = this.getADeclarationEntry())
  }
}

/**
 * Models the usage of a comparator.
 */
abstract class ComparatorUsage extends Locatable {
  /**
   * Gets the underlying comparator.
   */
  abstract Class getComparator();

  /**
   * Holds if the comparator is `std::less`.
   */
  predicate isLessThan() { getComparator().hasQualifiedName("std", "less") }

  /**
   * Holds if the comparator is `std::greater`.
   */
  predicate isGreaterThan() { getComparator().hasQualifiedName("std", "greater") }

  /**
   * Holds if the class implements the operator needed for the corresponding
   * comparator.
   */
  predicate implementsRequiredOperator() {
    exists(Class c |
      c = getComparator().getTemplateArgument(0) and
      (
        isLessThan() and
        exists(Operator op | op.inMemberOrFriendOf(c) and op.getName() = "operator<")
        or
        isGreaterThan() and
        exists(Operator op | op.inMemberOrFriendOf(c) and op.getName() = "operator>")
      )
    )
  }

  /**
   * Holds if the comparator is user defined (and annotated as such).
   */
  predicate isUserDefinedComparator() {
    getComparator() instanceof UserDefinedStrictlyWeakOrderingComparator
  }

  /**
   * Holds if the comparator is strictly weakly ordering, either axiomatically
   * (via an annotation) or by being the `std::less` or `std::greater` comparator.
   */
  predicate isStrictlyWeakOrdering() {
    // It is user defined
    isUserDefinedComparator()
    or
    // require that we are using a strict ordering predicate
    (isLessThan() or isGreaterThan()) and
    // also require that if the type is not a built in type that the appropriate
    // operator is implemented in the class
    (
      not getComparator().getTemplateArgument(0) instanceof BuiltInType
      implies
      implementsRequiredOperator()
    )
  }
}

/**
 * Models a comparator used in a sort function.
 */
class SortComparatorUsage extends ComparatorUsage {
  Class comparator;

  SortComparatorUsage() {
    exists(FunctionCall fc |
      fc = this and
      (
        fc.getTarget().hasQualifiedName("std", "sort") and
        (
          fc.getNumberOfArguments() = 3 and comparator = fc.getArgument(2).getType()
          or
          fc.getNumberOfArguments() = 4 and comparator = fc.getArgument(3).getType()
        )
        or
        fc.getTarget().hasQualifiedName("std", "stable_sort") and
        (fc.getNumberOfArguments() = 3 and comparator = fc.getArgument(2).getType())
        or
        fc.getTarget().hasQualifiedName("std", "partial_sort") and
        (fc.getNumberOfArguments() = 4 and comparator = fc.getArgument(3).getType())
      )
    )
  }

  override Class getComparator() { result = comparator }
}

/**
 * Models a comparator used with an STL container.
 */
class ContainerComparatorUsage extends ComparatorUsage {
  Class comparator;

  ContainerComparatorUsage() {
    exists(VariableDeclarationEntry decl |
      decl = this and
      (
        decl.getType().(Class).hasQualifiedName("std", "set") and
        comparator = decl.getType().(Class).getTemplateArgument(1)
        or
        decl.getType().(Class).hasQualifiedName("std", "multiset") and
        comparator = decl.getType().(Class).getTemplateArgument(1)
        or
        decl.getType().(Class).hasQualifiedName("std", "map") and
        comparator = decl.getType().(Class).getTemplateArgument(2)
        or
        decl.getType().(Class).hasQualifiedName("std", "multimap") and
        comparator = decl.getType().(Class).getTemplateArgument(2)
      )
    )
  }

  override Class getComparator() { result = comparator }
}

/*
 * It is very hard in general to determine a valid ordering predicate without
 * invoking a solver. For this reason this predicate uses some simple
 * heuristics to determine if the ordering predicate is valid.
 *
 * For built in types:
 *
 * The scenario we look for in this query is one where a ordering predicate has
 * been supplied to a STL container or sort algorithm. In this scenario, we
 * whitelist those which are strictly weak ordering predicates. For built in
 * types it is enough to just consider the use of std::greater and std::less as valid.
 *
 * For non-built-in types:
 *
 * For non-built in types, we consider the use of any of the valid ordering
 * predicates to be acceptable if the class being compared has the matching
 * operator overloaded in its definition. We do not examine the definition to
 * determine if in fact it is valid.
 */

query predicate problems(ComparatorUsage cu, string message) {
  not cu.isStrictlyWeakOrdering() and
  not isExcluded(cu, getQuery()) and
  message =
    "Comparator '" + cu.getComparator().getName() +
      "' used on container or sorting algorithm that is not strictly weakly ordered"
}
