/**
 * Provides a library which includes a `problems` predicate for reporting unreachable code.
 *
 * This problems predicate identifies unreachable code at the level of `BasicBlock`. We use
 * `BasicBlock`s for this because they represent sequences of statements which, according to the CFG,
 * are either all unreachable or all reachable, because control flow cannot escape from the middle
 * of the basic block.
 *
 * We use the `BasicBlock.isUnreachable()` predicate to identify `BasicBlock`s which are unreachable
 * according to our calculated control flow graph. In practice, this can resolve expressions used in
 * conditions which are constant, accesses of constant values (even across function boundaries), and
 * operations, recursively, on such expressions. There is no attempt made to resolve conditional
 * expressions which are not statically constant or derived directly from statically constant variables.
 *
 * One potential problem with using `BasicBlock`s is that for template functions the `BasicBlock` is
 * duplicated across multiple `Function` instances, one for uninstantiated templates, and one for
 * each instantiation. Rather than considering each template instantiation independently, we instead
 * only report a `BasicBlock` in a template as unreachable, if it is unreachable in all template
 * instantiations (and in the uninstantiated template). This helps avoid flagging examples such as
 * `return 1` as dead code in this example, where `T::isVal()` is statically deducible in some
 * template instantiations:
 * ```
 * template <class T> int f() {
 *   if (T::isVal()) return 1;
 *   return 2;
 * }
 * ```
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.deadcode.UnreachableCode

abstract class UnreachableCodeSharedQuery extends Query { }

Query getQuery() { result instanceof UnreachableCodeSharedQuery }

query predicate problems(UnreachableBasicBlock b, string message, Function f, string functionName) {
  // None of the basic blocks are excluded
  not isExcluded(b.getABasicBlock(), getQuery()) and
  message = "This statement in function $@ is unreachable." and
  // Exclude results where at least one of the basic blocks appears in a macro expansion, as
  // macros can easily result in unreachable blocks through no fault of the user of the macro
  not inMacroExpansion(b.getABasicBlock()) and
  f = b.getPrimaryFunction() and
  functionName = f.getName()
}
