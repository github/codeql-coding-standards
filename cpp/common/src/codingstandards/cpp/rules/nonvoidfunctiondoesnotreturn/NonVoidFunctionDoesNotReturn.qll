/**
 * Provides a library which includes a `problems` predicate for reporting value returning functions that do not return for all exit paths
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.EncapsulatingFunctions

abstract class NonVoidFunctionDoesNotReturnSharedQuery extends Query { }

Query getQuery() { result instanceof NonVoidFunctionDoesNotReturnSharedQuery }

predicate functionsMissingReturnStmt(Function f, ControlFlowNode blame) {
  f.fromSource() and
  exists(Type returnType |
    returnType = f.getUnspecifiedType() and
    not returnType instanceof VoidType and
    not returnType instanceof TemplateParameter
  ) and
  exists(ReturnStmt s |
    f.getAPredecessor() = s and
    (
      blame = s.getAPredecessor() and
      count(blame.getASuccessor()) = 1
      or
      blame = s and
      exists(ControlFlowNode pred | pred = s.getAPredecessor() | count(pred.getASuccessor()) != 1)
    )
  )
}

predicate functionImperfectlyExtracted(Function f) {
  exists(CompilerError e | f.getBlock().getLocation().subsumes(e.getLocation()))
  or
  exists(ErrorExpr ee | ee.getEnclosingFunction() = f)
  or
  count(f.getType()) > 1
  or
  // an `AsmStmt` isn't strictly 'imperfectly extracted', but it's beyond the scope
  // of this analysis.
  exists(AsmStmt asm | asm.getEnclosingFunction() = f)
}

query predicate problems(ControlFlowNode blame, string message) {
  exists(Function f, Stmt stmt |
    not isExcluded(f, getQuery()) and
    not f instanceof MainFunction and
    functionsMissingReturnStmt(f, blame) and
    reachable(blame) and
    not functionImperfectlyExtracted(f) and
    (blame = stmt or blame.(Expr).getEnclosingStmt() = stmt) and
    message =
      "Function " + f.getName() + " should return a value of type " + f.getType().getName() +
        " but does not return a value here"
  )
}
