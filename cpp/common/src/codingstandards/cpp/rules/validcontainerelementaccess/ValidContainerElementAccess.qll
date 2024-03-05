/**
 * This query works by considering two different types of container access and
 * determining if they are valid along a access path. It works with both
 * straight line and code with loops.
 *
 * Essentially there are two types of container access: access to a container
 * through an iterator and access to a container via a pointer or reference
 * obtained by an element. These references and iterators may be invalidated by
 * the use of various APIs within the STL container libraries. E.g.,
 * `std::vector::clear` may impact a reference held by a pointer or impact an
 * operation to an existing iterator. The interaction of these two elements have
 * very complicated semantics so the aim of this rule and query implementation
 * is to consider a call to any of these function as invalidations of the
 * pointer, reference, or iterator.
 *
 * To do this, this query considers all container accesses and considers the
 * invalidation operations that may be performed on them. In the case where an
 * invalidation "reaches" the container access the container access is said to
 * be invalid. In this query, a `ContainerInvalidationOperation` reaches a
 * `ContainerAccess` if there does not exist a subsequent
 * `ContainerRevalidationOperation` for the given container access element that
 * occurs on the path from the invalidation to the access.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Iterators

abstract class ValidContainerElementAccessSharedQuery extends Query { }

Query getQuery() { result instanceof ValidContainerElementAccessSharedQuery }

query predicate problems(
  ContainerAccess ca, string message, Variable containerVariable, string elementType,
  ContainerInvalidationOperation cio, string actionType
) {
  not isExcluded(cio, getQuery()) and
  not isExcluded(ca, getQuery()) and
  // The definition of an invalidation is slightly different
  // for references vs iterators -- this check ensures that the conditions
  // under which a call should be an invalidator are considered correctly.
  (
    ca instanceof ContainerIteratorAccess and not cio.taintsVariables()
    or
    ca instanceof ContainerPointerOrReferenceAccess
  ) and
  invalidationReaches(cio, ca) and
  containerVariable = ca.getOwningContainer() and
  message =
    "Elements of $@ not accessed with valid reference, pointer, or iterator because of a prior $@." and
  elementType = "container" and
  actionType = "invalidation"
}
