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
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.security.BufferWrite
import semmle.code.cpp.dataflow.DataFlow

/**
 * Class that includes into `BufferWrite` functions that will modify their
 * first argument. This is an extension of `BufferWrite` which covers the case
 * of opaque writes via library functions.
 */
class ModifiesFirstArgFunction extends BufferWrite, FunctionCall {
  Expr modifiedExpr;

  ModifiesFirstArgFunction() {
    getTarget().getName() = ["mkstemp", "memset", "memcpy", "memmove"] and
    getArgument(0) = modifiedExpr
  }

  override Type getBufferType() { none() }

  override Expr getDest() { result = modifiedExpr }
}

/**
 * Models a dataflow wherein a source is either a implicit or explicit string
 * literal that is assigned to a non modifiable type or wherein the string
 * literal arises as a argument to a function that may modify its argument.
 */
class ImplicitOrExplicitStringLiteralModifiedConfiguration extends DataFlow::Configuration {
  ImplicitOrExplicitStringLiteralModifiedConfiguration() {
    this = "ImplicitOrExplicitStringLiteralModifiedConfiguration"
  }

  override predicate isSource(DataFlow::Node node) {
    // usage through variables
    exists(Variable v |
      v.getAnAssignedValue() = node.asExpr() and
      (
        node.asExpr() instanceof ImplicitStringLiteral or
        node.asExpr() instanceof StringLiteralOrConstChar
      ) and
      v.getType().getUnderlyingType() instanceof CharPointerType
    )
    or
    // direct usage of string literals as function parameters
    exists(BufferWrite bw |
      bw.getDest() = node.asExpr() and
      (
        node.asExpr() instanceof ImplicitStringLiteral or
        node.asExpr() instanceof StringLiteralOrConstChar
      )
    )
  }

  override predicate isSink(DataFlow::Node node) {
    // it's either a buffer write of some kind that we
    // know about
    exists(BufferWrite bw | bw.getDest() = node.asExpr())
    or
    // or it is a direct assignment of some kind - including reassignment of the pointer
    exists(AssignExpr aexp | aexp.getLValue().(ArrayExpr).getArrayBase() = node.asExpr())
    or
    exists(AssignExpr aexp | aexp.getLValue().(PointerDereferenceExpr).getOperand() = node.asExpr())
  }
}

class MaybeReturnsStringLiteralFunctionCall extends FunctionCall {
  MaybeReturnsStringLiteralFunctionCall() {
    getTarget().getName() in [
        "strpbrk", "strchr", "strrchr", "strstr", "wcspbrk", "wcschr", "wcsrchr", "wcsstr",
        "memchr", "wmemchr"
      ]
  }
}

class ImplicitStringLiteral extends Expr {
  ImplicitStringLiteral() {
    exists(MaybeReturnsStringLiteralFunctionCall fc, Variable e |
      e.getAnAssignedValue() = fc and
      this = fc and
      // additionally, we require that the first argument is either an explicit
      // or implicit string literal
      (
        // directly a string literal
        fc.getArgument(0) instanceof StringLiteralOrConstChar
        or
        // a string literal flows into it
        exists(StringLiteralOrConstChar sl |
          DataFlow::localFlow(DataFlow::exprNode(sl), DataFlow::exprNode(fc.getArgument(0)))
        )
        or
        // or a base flows into it
        exists(ImplicitStringLiteralBase base |
          DataFlow::localFlow(DataFlow::exprNode(base), DataFlow::exprNode(fc.getArgument(0)))
        )
      )
    )
  }
}

class StringLiteralOrConstChar extends Expr {
  StringLiteralOrConstChar() {
    this instanceof StringLiteral
    or
    getUnspecifiedType() instanceof CharPointerType and
    getType().(PointerType).getBaseType().isConst()
  }
}

/**
 * Since it is possible to produce an implicit literal by either
 * an explicit literal being passed to one of these functions this
 * class exists to establish the "base" type, that is an explicit
 * string literal passed or flowing into the first argument. The other
 * Implicit string literal class will then check to see if it is inductively
 * an implicit string literal.
 */
class ImplicitStringLiteralBase extends Expr {
  ImplicitStringLiteralBase() {
    exists(MaybeReturnsStringLiteralFunctionCall fc, Variable e |
      e.getAnAssignedValue() = fc and
      this = fc and
      // it either directly gets a string literal or one via flow
      (
        fc.getArgument(0) instanceof StringLiteralOrConstChar or
        exists(StringLiteralOrConstChar sl |
          DataFlow::localFlow(DataFlow::exprNode(sl), DataFlow::exprNode(fc.getArgument(0)))
        )
      )
    )
  }
}

from Expr literal, Expr literalWrite, ImplicitOrExplicitStringLiteralModifiedConfiguration config
where
  not isExcluded(literal, Strings1Package::doNotAttemptToModifyStringLiteralsQuery()) and
  not isExcluded(literalWrite, Strings1Package::doNotAttemptToModifyStringLiteralsQuery()) and
  config.hasFlow(DataFlow::exprNode(literal), DataFlow::exprNode(literalWrite))
select literalWrite,
  "This operation may write to a string that may be a string literal that was $@.", literal,
  "created here"
