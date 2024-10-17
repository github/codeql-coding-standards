/**
 * This module provides some predicates to
 */

import cpp

/**
 * This relation is the same as the `el instanceof Function`, only obfuscated
 * so the optimizer will not understand that any `FunctionCall.getTarget()`
 * should be in this relation.
 */
pragma[noinline]
private predicate isFunction(@element el) {
  el instanceof @function
  or
  el.(Expr).getParent() = el
}

/**
 * Holds if `fc` is a `FunctionCall` with no return value for `getTarget`. This
 * can happen due to extractor issue CPP-383.
 */
pragma[noopt]
private predicate callHasNoTarget(@funbindexpr fc) {
  exists(@function f |
    funbind(fc, f) and
    not isFunction(f)
  )
}

/**
 * Holds if the control flow graph for `Function` `f` is likely broken due to a control flow graph
 * bug.
 *
 * If the extractor produces an inconsistent database where functions are only populated at call
 * sites (`funbind` relation), and not within the `functions` relation, this can cause the creation
 * of invalid control flow graphs with certain versions of the CodeQL C++ Standard Library. In
 * particular, it can cause CFGs where nodes are incorrectly inferred as unreachable.
 *
 * This has now been addressed in the CodeQL C++ Standard Library:
 *
 *   https://github.com/github/codeql/pull/5696
 *
 * But, at the time of writing, the fix is not available in the currently targeted version of the
 * CodeQL Standard Library (v1.26.0).
 *
 * This predicate determines:
 *  (a) Whether the given function is susceptible to this issue.
 *  (b) Whether the workaround appears to be in place.
 *
 * The latter ensures that if these queries are used with a new enough library, we will not exclude
 * functions unnecessarily. However, once we officially support a new enough version, this
 * workaround can and should be removed.
 */
predicate hasInvalidCFG(Function f) {
  exists(FunctionCall fc |
    fc.getEnclosingFunction() = f and
    // If this has successors, then the workaround is likely in place
    not exists(fc.getASuccessor())
  |
    callHasNoTarget(fc)
    or
    hasInvalidCFG(fc.getTarget())
  )
}
