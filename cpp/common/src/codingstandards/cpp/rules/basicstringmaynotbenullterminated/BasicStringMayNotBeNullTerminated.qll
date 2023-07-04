/**
 * Implements a query that detects cases wherein a `std::string` may not be
 * null-terminated.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.security.BufferWrite
import semmle.code.cpp.commons.Buffer
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.PossiblyUnsafeStringOperation

abstract class BasicStringMayNotBeNullTerminatedSharedQuery extends Query { }

Query getQuery() { result instanceof BasicStringMayNotBeNullTerminatedSharedQuery }

class BasicStringClass extends Class {
  BasicStringClass() { getSimpleName() = "basic_string" }
}

class BasicStringConstructorCall extends ConstructorCall {
  BasicStringConstructorCall() { getTarget().getDeclaringType() instanceof BasicStringClass }
}

class PossiblySafeStringOperation extends FunctionCall {
  PossiblySafeStringOperation() {
    not this instanceof PossiblyUnsafeStringOperation and
    this.getTarget() instanceof StandardCStringFunction
  }
}

query predicate problems(BasicStringConstructorCall cc, string message) {
  exists(Expr arg |
    not isExcluded(cc, getQuery()) and
    arg = cc.getArgument(0) and
    // Find cases where the argument to the constructor:
    //
    // a) is not a string literal
    not arg instanceof StringLiteral and
    // b) may exist in a dataflow from an unsafe usage of a string function
    exists(PossiblyUnsafeStringOperation op |
      TaintTracking::localTaint(DataFlow::exprNode(op.getAnArgument()), DataFlow::exprNode(arg))
    ) and
    message = "Construction of string object with possibly non-null terminated C-style string."
  )
}
