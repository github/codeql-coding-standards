/**
 * Provides a library which includes a `problems` predicate for reporting reads of uninitialized memory.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.controlflow.Guards
import semmle.code.cpp.controlflow.SubBasicBlocks

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

/**
 * A `SubBasicBlockCutNode` that ensures that any uninitialized variable definitions appear at the
 * start of a `SubBasicBlock`.
 */
class InitializationSubBasicBlock extends SubBasicBlockCutNode {
  InitializationSubBasicBlock() { this = any(UninitializedVariable uv).getADefinitionAccess() }
}

/**
 * Holds if the `gc` dictates the state of variable `lv`, i.e. the state is heuristically
 * identified to be different under different branches.
 */
private predicate guardDictatesLocalVariableState(
  GuardCondition gc, LocalScopeVariable lv, boolean lvStateOnTrueBranch
) {
  // Condition is a boolean check on the variable
  gc = lv.getAnAccess() and lvStateOnTrueBranch = true
  or
  // Condition is a negated boolean check on the variable
  gc.(NotExpr).getOperand() = lv.getAnAccess() and lvStateOnTrueBranch = false
  or
  // Condition controls a block which assigns to `lv`
  gc.controls(lv.getAnAssignedValue().getBasicBlock(), lvStateOnTrueBranch)
}

private newtype TInitializationContext =
  /** No specific context - for functions where conditional initialization doesn't play a role */
  NoContext(UninitializedVariable uv) { count(uv.getACorrelatedConditionVariable()) = 0 } or
  /**
   * A context where the given `LocalScopeVariable` is identified as a correlated variable with the
   * given state value.
   */
  CorrelatedVariable(UninitializedVariable uv, LocalScopeVariable correlatedVariable, boolean state) {
    uv.getACorrelatedConditionVariable() = correlatedVariable and state = [true, false]
  }

/**
 * A context to apply when determining whether a given variable is uninitialized at a particular
 * `SubBasicBlock` in the control flow graph.
 *
 * If no suitable context is found for an `UninitializedVariable`, `NoContext` is used.
 *
 * If one or more correlated variables are found, a `CorrelatedVariable` context is provided, with
 * `true` and `false` states.
 */
class InitializationContext extends TInitializationContext {
  /**
   * Gets the `UninitializedVariable` for this context.
   */
  UninitializedVariable getUninitializedVariable() {
    this = NoContext(result) or
    this = CorrelatedVariable(result, _, _)
  }

  /**
   * Gets the correlated variable, if any.
   */
  LocalScopeVariable getCorrelatedVariable() { this = CorrelatedVariable(_, result, _) }

  string toString() {
    if this instanceof CorrelatedVariable
    then
      result =
        "Uninitialized variable " + getUninitializedVariable().getName() + " where location " +
          getCorrelatedVariable().getName() + " is " +
          any(boolean b | this = CorrelatedVariable(_, _, b))
    else result = "Uninitialized variable " + getUninitializedVariable().getName()
  }
}

/**
 * A local variable without an initializer which is amenable to initialization analysis.
 */
class UninitializedVariable extends LocalVariable {
  UninitializedVariable() {
    // Not initialized at declaration
    not exists(getInitializer()) and
    // Not static or thread local, because they are not initialized with indeterminate values
    not isStatic() and
    not isThreadLocal() and
    // Not atomic, which have special initialization rules
    not getType().hasSpecifier("atomic") and
    // Not a class type, because default initialization of a class calls the default constructor
    // The default constructor may leave certain fields uninitialized, but that would be a separate
    // field-wise analysis
    not this.getType().getUnspecifiedType() instanceof Class and
    // An analysis of an array entry also requires a field wise analysis
    not this.getType().getUnspecifiedType() instanceof ArrayType and
    // Ignore variables in uninstantiated templates, because we often do not have enough semantic
    // information to accurately determine initialization state.
    not isFromUninstantiatedTemplate(_) and
    // Ignore `va_list`, that is part of the mechanism for
    not getType().hasName("va_list") and
    // Ignore variable defined in a block with an `asm` statement, as that may initialized the variables
    not exists(AsmStmt asm | asm.getEnclosingBlock() = getParentScope()) and
    // Ignore variables generated for `RangeBasedForStmt` e.g. `for(auto x : y)`
    not this = any(RangeBasedForStmt f).getAChild().(DeclStmt).getADeclaration()
  }

  /** Gets a variable correlated with at least one use of `this` uninitialized variable. */
  private LocalScopeVariable getAUseCorrelatedConditionVariable() {
    /* Extracted to improve join order of getACorrelatedConditionVariable(). */
    // The use is guarded by the access of a variable
    exists(GuardCondition gc |
      gc.controls(getAUse().getBasicBlock(), _) and
      gc = result.getAnAccess()
    )
  }

  /** Find another variable which looks like it may be correlated with the initialization of this variable. */
  pragma[noinline]
  LocalScopeVariable getACorrelatedConditionVariable() {
    result = getAUseCorrelatedConditionVariable() and
    (
      // Definition is guarded by an access of the same variable
      exists(GuardCondition gc |
        gc.controls(getADefinitionAccess().getBasicBlock(), _) and
        gc = result.getAnAccess()
      )
      or
      // The variable is assigned in the same basic block as one of our definitions
      result.getAnAssignedValue().getBasicBlock() = getADefinitionAccess().getBasicBlock()
    )
  }

  /** Get a access of the variable that is used to initialize the variable. */
  VariableAccess getADefinitionAccess() {
    result = getAnAccess() and
    result.isLValueCategory()
  }

  /** Get a read of the variable. */
  VariableAccess getAUse() {
    result = getAnAccess() and
    result.isRValueCategory() and
    // sizeof operators are not real uses
    not result.getParent+() instanceof SizeofOperator
  }

  /** Get a read of the variable that may occur while the variable is uninitialized. */
  VariableAccess getAnUnitializedUse() {
    exists(SubBasicBlock useSbb |
      result = getAUse() and
      useSbb.getANode() = result and
      // This sbb is considered uninitialized in all the contexts we identified
      forex(InitializationContext ct | ct.getUninitializedVariable() = this |
        useSbb = getAnUninitializedSubBasicBlock(ct)
      )
    )
  }

  /**
   * Gets a `SubBasicBlock` where this variable is uninitialized under the conditions specified by
   * `InitializationContext`.
   */
  private SubBasicBlock getAnUninitializedSubBasicBlock(InitializationContext ic) {
    ic.getUninitializedVariable() = this and
    (
      // Base case - this SBB is the one that declares the variable
      exists(DeclStmt ds |
        ds.getADeclaration() = this and
        result.getANode() = ds
      )
      or
      // Recursive case - SBB is a successor of an SBB where this variable is uninitialized
      exists(SubBasicBlock mid |
        // result is the successor of an SBB where this is considered to be uninitialized under the
        // context ic
        mid = getAnUninitializedSubBasicBlock(ic) and
        result = mid.getASuccessor() and
        // Result is not an SBB where this variable is initialized
        not getADefinitionAccess() = result and
        // Determine if this is a branch at __builtin_expect where the initialization occurs inside
        // the checked argument, and exclude it if so, because the CFG is known to be broken here.
        not exists(FunctionCall fc |
          mid.getEnd() = fc and
          fc.getTarget().hasName("__builtin_expect") and
          fc.getArgument(0).getAChild*() = getADefinitionAccess()
        )
      |
        // If this is an analysis with no context
        ic = NoContext(this)
        or
        exists(LocalScopeVariable lv | lv = ic.getCorrelatedVariable() |
          // If the final node in `mid` SBB is a guard condition that affects our tracked correlated
          // variable
          guardDictatesLocalVariableState(mid.getEnd(), lv, _)
          implies
          // Then our context must match the inferred state of the correlated variable after the branch
          exists(boolean lvStateOnTrueBranch |
            guardDictatesLocalVariableState(mid.getEnd(), lv, lvStateOnTrueBranch)
          |
            result = mid.getATrueSuccessor() and
            ic = CorrelatedVariable(this, lv, lvStateOnTrueBranch)
            or
            result = mid.getAFalseSuccessor() and
            ic = CorrelatedVariable(this, lv, lvStateOnTrueBranch.booleanNot())
          )
        )
      )
    )
  }
}

query predicate problems(VariableAccess va, string message, UninitializedVariable uv, string name) {
  not isExcluded(va, getQuery()) and
  name = uv.getName() and
  va = uv.getAnUnitializedUse() and
  message = "Local variable $@ is read here and may not be initialized on all paths."
}
