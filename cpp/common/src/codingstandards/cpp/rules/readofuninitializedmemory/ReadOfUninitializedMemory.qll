/**
 * Provides a library which includes a `problems` predicate for reporting reads of uninitialized memory.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.InitializationContext

abstract class ReadOfUninitializedMemorySharedQuery extends Query { }

Query getQuery() { result instanceof ReadOfUninitializedMemorySharedQuery }

/*
 * This strategy for this query is to find uninitialized local variable declarations and find paths
 * through the control flow graph from their declaration location to a use of the local variable
 * without traversing through an assignment or write to the local variable.
 *
 * The implementation uses `SubBasicBlock`s for efficiency. Instead of traversing through every
 * control flow node, we use `SubBasicBlockCutNode` to mark every definition to a candidate
 * uninitialized local variable as the start of a sub basic block. We then identify `SubBasicBlock`s
 * which can be reached from the declaration `SubBasicBlock` without going through a `SubBasicBlock`
 * that initializes the uninitialized local variable.
 *
 * It is often the case that an uninitialized variable is initialized on some, but not all, paths in
 * the program. For example, consider:
 * ```
 * int y;
 * if (x) {
 *   y = 0;
 * }
 * if (x) {
 *   use(y);
 * }
 * ```
 * If we were to use a path-insensitive analysis, we would be unable to determine that `y` is always
 * initialized when used.
 *
 * We resolve this issue by providing a _context_ when identifying SBBs where the local variable
 * remains uninitialized. This context can either be "NoContext", or it can represent the value of
 * a _correlated variable_, i.e. a variable whose value is correlated with the use and definition
 * of the uninitialized variable. In our example, `x` is a correlated variable for `y`.
 *
 * We identify candidates for these correlated variables by determining which variables are checked
 * in guards around uses. If no candidates are found, we perform a path insensitive analysis using
 * our "NoContext" context. If candidates are found, we perform a path sensitive analysis for each
 * correlated variable and for each state of that variable (`true` and `false`).
 *
 * We then assert that a use is of an uninitialized variable if it is uninitialized in all the
 * contexts we attempted for.
 */

query predicate problems(VariableAccess va, string message, UninitializedVariable uv, string name) {
  not isExcluded(va, getQuery()) and
  name = uv.getName() and
  va = uv.getAnUnitializedUse() and
  message = "Local variable $@ is read here and may not be initialized on all paths."
}
