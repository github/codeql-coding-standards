/**
 * @id c/cert/non-null-terminated-to-function-that-expects-a-string
 * @name STR32-C: Do not pass a non-null-terminated character sequence to a library function that expects a string
 * @description Passing a string that is not null-terminated can lead to unpredictable program
 *              behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/str32-c
 *       correctness
 *       security
 *       external/cert/severity/high
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p12
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.Naming
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.PossiblyUnsafeStringOperation
import semmle.code.cpp.valuenumbering.GlobalValueNumbering

/**
 * Models a function that is part of the standard library that expects a
 * null-terminated string as an argument. Note that most standard library
 * functions expect this; as a simplifying assumption we assume that a flow
 * into these functions implies such a usage.
 */
class ExpectsNullTerminatedStringAsArgumentFunctionCall extends FunctionCall {
  Expr e;

  ExpectsNullTerminatedStringAsArgumentFunctionCall() {
    Naming::Cpp14::hasStandardLibraryFunctionName(getTarget().getName()) and
    exists(Type t |
      e = getAnArgument() and
      t = getTarget().getAParameter().getType().(DerivedType).getBaseType*() and
      (t instanceof CharType or t instanceof Wchar_t)
    )
  }

  /**
   * This predicate will produce a result equal to any argument of a function
   * that expects null-terminated strings.
   */
  Expr getAnExpectingExpr() { result = e }
}

class PossiblyUnsafeStringOperationSource extends Source {
  PossiblyUnsafeStringOperation op;

  PossiblyUnsafeStringOperationSource() { this.asExpr() = op.getAnArgument() }

  PossiblyUnsafeStringOperation getOp() { result = op }
}

class CharArraySource extends Source {
  CharArrayInitializedWithStringLiteral op;

  CharArraySource() {
    op.getContainerLength() <= op.getStringLiteralLength() and
    this.asExpr() = op
  }
}

abstract class Source extends DataFlow::Node { }

class Sink extends DataFlow::Node {
  Sink() {
    exists(ExpectsNullTerminatedStringAsArgumentFunctionCall fc |
      fc.getAnExpectingExpr() = this.asExpr()
    )
  }
}

module MyFlowConfiguration implements DataFlow::ConfigSig {
  predicate isSink(DataFlow::Node sink) {
    sink instanceof Sink and
    //don't report violations of the same function call
    not sink instanceof Source
  }

  predicate isSource(DataFlow::Node source) { source instanceof Source }

  predicate isAdditionalFlowStep(DataFlow::Node innode, DataFlow::Node outnode) {
    exists(FunctionCall realloc, ReallocFunction fn |
      fn.getACallToThisFunction() = realloc and
      realloc.getArgument(0) = innode.asExpr() and
      realloc = outnode.asExpr()
    )
  }
}

class ReallocFunction extends AllocationFunction {
  ReallocFunction() { exists(this.getReallocPtrArg()) }
}

/**
 * Determines if the string is acceptably null terminated
 * The only condition we accept as a guarantee to null terminate is:
 * `str[size_expr] = '\0';`
 * where we do not check the value of the `size_expr` used
 */
predicate isGuarded(Expr guarded, Expr source) {
  exists(AssignExpr aexp |
    aexp.getLValue() instanceof ArrayExpr and
    aexp.getRValue() instanceof Zero and
    // this must be AFTER the operation causing the non-null termination
    aexp.getAPredecessor+() = source and
    //this guards anything after it
    aexp.getASuccessor+() = guarded and
    // no reallocs exist after this because they will be conservatively assumed to make the buffer smaller and remove the likliehood of this properly terminating
    not exists(ReallocFunction realloc, FunctionCall fn |
      fn = realloc.getACallToThisFunction() and
      globalValueNumber(aexp.getLValue().(ArrayExpr).getArrayBase()) =
        globalValueNumber(fn.getArgument(0)) and
      aexp.getASuccessor+() = fn
    )
  )
}

module MyFlow = TaintTracking::Global<MyFlowConfiguration>;

from
  DataFlow::Node source, DataFlow::Node sink, ExpectsNullTerminatedStringAsArgumentFunctionCall fc,
  Expr e
where
  MyFlow::flow(source, sink) and
  sink.asExpr() = fc.getAnExpectingExpr() and
  not isGuarded(sink.asExpr(), source.asExpr()) and
  if source instanceof PossiblyUnsafeStringOperationSource
  then e = source.(PossiblyUnsafeStringOperationSource).getOp()
  else e = source.asExpr()
select fc, "String modified by $@ is passed to function expecting a null-terminated string.", e,
  "this expression"
