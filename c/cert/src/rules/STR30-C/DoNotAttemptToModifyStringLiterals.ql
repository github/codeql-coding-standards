/**
 * @id c/cert/do-not-attempt-to-modify-string-literals
 * @name STR30-C: Do not attempt to modify string literals
 * @description Modifying a string literal can produce unexpected effects.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/str30-c
 *       correctness
 *       security
 *       external/cert/severity/low
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/low
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.security.BufferWrite
import semmle.code.cpp.dataflow.new.DataFlow

/** A modeled buffer write through the first argument of a library call. */
private class ModifiesFirstArgFunction extends BufferWrite, FunctionCall {
  ModifiesFirstArgFunction() {
    getTarget().getName() = ["mkstemp", "memset", "memcpy", "memmove"]
  }

  override Type getBufferType() { none() }

  override Expr getDest() { result = getArgument(0) }
}

/** Provides dataflow from assigned string literals to writes. */
private module StringLiteralConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node node) {
    exists(Variable v |
      v.getAnAssignedValue() = node.asExpr() and
      mayBeStringLiteral(node.asExpr()) and
      v.getType().getUnderlyingType() instanceof CharPointerType
    )
  }

  predicate isSink(DataFlow::Node node) {
    node.asExpr() = any(BufferWrite bw).getDest()
    or
    node.asExpr() = any(AssignExpr a).getLValue().(ArrayExpr).getArrayBase()
    or
    node.asExpr() = any(AssignExpr a).getLValue().(PointerDereferenceExpr).getOperand()
  }
}

/** Provides dataflow from possible string literals to writes. */
private module StringLiteralFlow {
  private module Global = DataFlow::Global<StringLiteralConfig>;

  /** Holds if `source` may point to a string literal that is written at `sink`. */
  predicate flow(Expr source, Expr sink) {
    // Report the pointer operand rather than a dereference represented by the same dataflow node.
    not sink instanceof PointerDereferenceExpr and
    (
      Global::flow(DataFlow::exprNode(source), DataFlow::exprNode(sink))
      or
      source = sink and
      mayBeStringLiteral(sink) and
      sink = any(BufferWrite bw).getDest()
    )
  }
}

/** A call that may return a pointer into a possible string literal. */
private class ImplicitStringLiteral extends FunctionCall {
  ImplicitStringLiteral() {
    getTarget().getName() in [
        "strpbrk", "strchr", "strrchr", "strstr", "wcspbrk", "wcschr", "wcsrchr", "wcsstr",
        "memchr", "wmemchr"
      ] and
    exists(Variable v | v.getAnAssignedValue() = this) and
    exists(Expr source |
      mayBeStringLiteral(source) and DataFlow::localExprFlow(source, getArgument(0))
    )
  }
}

/** Holds if `e` may point to a string literal. */
private predicate mayBeStringLiteral(Expr e) {
  e instanceof StringLiteral
  or
  e.getUnspecifiedType() instanceof CharPointerType and
  e.getType().(PointerType).getBaseType().isConst()
  or
  e instanceof ImplicitStringLiteral
}

from Expr literal, Expr literalWrite
where
  not isExcluded(literal, Strings1Package::doNotAttemptToModifyStringLiteralsQuery()) and
  not isExcluded(literalWrite, Strings1Package::doNotAttemptToModifyStringLiteralsQuery()) and
  StringLiteralFlow::flow(literal, literalWrite)
select literalWrite,
  "This operation may write to a string that may be a string literal that was $@.", literal,
  "created here"
