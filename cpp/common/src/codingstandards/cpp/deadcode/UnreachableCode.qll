/**
 * A module for identifying unreachable basic blocks
 */

import cpp

predicate isCompilerGenerated(BasicBlock b) {
  b.(Stmt).isCompilerGenerated()
  or
  b.(Expr).isCompilerGenerated()
}

/**
 * A newtype representing "unreachable" blocks in the program. We use a newtype here to avoid
 * reporting the same block in multiple `Function` instances created from one function in a template.
 */
private newtype TUnreachableBasicBlock =
  TUnreachableNonTemplateBlock(BasicBlock bb) {
    bb.isUnreachable() and
    // Exclude anything template related from this case
    not bb.getEnclosingFunction().isFromTemplateInstantiation(_) and
    not bb.getEnclosingFunction().isFromUninstantiatedTemplate(_) and
    // Exclude compiler generated basic blocks
    not isCompilerGenerated(bb)
  } or
  /**
   * A `BasicBlock` that occurs in at least one `Function` instance for a template. `BasicBlock`s
   * are matched up across templates by location.
   */
  TUnreachableTemplateBlock(
    string filepath, int startline, int startcolumn, int endline, int endcolumn,
    Function uninstantiatedFunction
  ) {
    forex(BasicBlock bb |
      // BasicBlock occurs in this location
      bb.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn) and
      // And is contained in the `uninstantiatedFunction` or a function constructed from it
      exists(Function enclosing | enclosing = bb.getEnclosingFunction() |
        enclosing.isConstructedFrom(uninstantiatedFunction)
        or
        enclosing = uninstantiatedFunction and
        uninstantiatedFunction.isFromUninstantiatedTemplate(_)
      )
    |
      // And is unreachable
      bb.isUnreachable() and
      // Exclude compiler generated control flow nodes
      not isCompilerGenerated(bb) and
      // Exclude nodes affected by macros, because our find-the-same-basic-block-by-location doesn't
      // work in that case
      not bb.(ControlFlowNode).isAffectedByMacro()
    )
  }

/**
 * An unreachable basic block.
 */
class UnreachableBasicBlock extends TUnreachableBasicBlock {
  /** Gets a `BasicBlock` which is represented by this set of unreachable basic blocks. */
  BasicBlock getABasicBlock() { none() }

  /** Gets a `Function` instance which we treat as the original function. */
  Function getPrimaryFunction() { none() }

  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    none()
  }

  string toString() { result = "default" }
}

/**
 * A non-templated unreachable basic block.
 */
class UnreachableNonTemplateBlock extends UnreachableBasicBlock, TUnreachableNonTemplateBlock {
  BasicBlock getBasicBlock() { this = TUnreachableNonTemplateBlock(result) }

  override BasicBlock getABasicBlock() { result = getBasicBlock() }

  override Function getPrimaryFunction() { result = getBasicBlock().getEnclosingFunction() }

  override predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    getBasicBlock().hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn)
  }

  override string toString() { result = getBasicBlock().toString() }
}

/**
 * A templated unreachable basic block.
 */
class UnreachableTemplateBlock extends UnreachableBasicBlock, TUnreachableTemplateBlock {
  override BasicBlock getABasicBlock() {
    exists(
      string filepath, int startline, int startcolumn, int endline, int endcolumn,
      Function uninstantiatedFunction
    |
      this =
        TUnreachableTemplateBlock(filepath, startline, startcolumn, endline, endcolumn,
          uninstantiatedFunction) and
      result.hasLocationInfo(filepath, startline, startcolumn, endline, endcolumn) and
      exists(Function enclosing |
        enclosing = result.getEnclosingFunction() and enclosing.isFromUninstantiatedTemplate(_)
      |
        enclosing.isConstructedFrom(uninstantiatedFunction) or enclosing = uninstantiatedFunction
      )
    |
      result.isUnreachable() and
      // Exclude compiler generated control flow nodes
      not isCompilerGenerated(result) and
      // Exclude nodes affected by macros, because our find-the-same-basic-block-by-location doesn't
      // work in that case
      not result.(ControlFlowNode).isAffectedByMacro()
    )
  }

  override Function getPrimaryFunction() { this = TUnreachableTemplateBlock(_, _, _, _, _, result) }

  override predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    this = TUnreachableTemplateBlock(filepath, startline, startcolumn, endline, endcolumn, _)
  }

  override string toString() { result = getABasicBlock().toString() }
}
