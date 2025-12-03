/**
 * @id c/misra/nonstandard-use-of-threading-object
 * @name RULE-22-12: Standard library threading objects (mutexes, threads, etc.) shall only be accessed by the appropriate Standard Library functions
 * @description Thread objects, thread synchronization objects, and thread-specific storage pointers
 *              shall only be accessed by the appropriate Standard Library functions.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-12
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.Concurrency
import codingstandards.cpp.types.Resolve

predicate isThreadingObject(Type t) {
  t instanceof ResolvesTo<C11ThreadingObjectType>::IgnoringSpecifiers
}

predicate validUseOfStdThreadObject(Expr e) {
  e.getParent() instanceof AddressOfExpr
  or
  exists(Call c |
    c.getTarget().hasName(["tss_get", "tss_set", "tss_delete"]) and
    e = c.getArgument(0)
  )
}

predicate isStdThreadObjectPtr(Type t) { isThreadingObject(t.(PointerType).getBaseType()) }

predicate invalidStdThreadObjectUse(Expr e) {
  // Invalid use of mtx_t, etc.
  isThreadingObject(e.getType()) and
  not validUseOfStdThreadObject(e)
  or
  // Invalid cast from mtx_t* to void*, etc.
  isStdThreadObjectPtr(e.getType()) and
  exists(Cast cast |
    cast.getExpr() = e and
    not isStdThreadObjectPtr(cast.getType())
  )
}

from Expr e
where
  not isExcluded(e, Concurrency8Package::nonstandardUseOfThreadingObjectQuery()) and
  invalidStdThreadObjectUse(e) and
  // Deduplicate results: (mtx = mtx) is an expression of mtx type, but don't flag the equality
  // check, only flag the two `mtx` references.
  not invalidStdThreadObjectUse(e.getAChild+())
select e, "Invalid usage of standard thread object type '" + e.getType().toString() + "'."
