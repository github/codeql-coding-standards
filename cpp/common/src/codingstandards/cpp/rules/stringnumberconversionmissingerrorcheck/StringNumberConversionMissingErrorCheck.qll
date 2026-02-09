/**
 * Provides a library which includes a `problems` predicate for reporting missing error state
 * checking after a call to a string-to-number conversion function.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.standardlibrary.CharStreams

abstract class StringNumberConversionMissingErrorCheckSharedQuery extends Query { }

Query getQuery() { result instanceof StringNumberConversionMissingErrorCheckSharedQuery }

/**
 * A source of a `CharIStream`.
 */
abstract class CharIStreamSource extends Element {
  /** A use of this source stream. */
  abstract Expr getAUse();
}

/**
 * A `CharIStream` created by a `ConstructorCall`.
 */
class CharIStreamConstructorCall extends CharIStreamSource, Expr {
  CharIStreamConstructorCall() {
    this.(ConstructorCall).getTarget().getDeclaringType().getABaseClass*() instanceof CharIStream
  }

  override Expr getAUse() {
    CharIStreamConstructorCallUseFlow::flow(DataFlow::exprNode(this), DataFlow::exprNode(result))
  }
}

/**
 * A global taint tracking configuration used to track from `CharIStream` constructor calls to uses
 * of that stream later in the program.
 */
private module CharIStreamConstructorCallUseConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof CharIStreamConstructorCall
  }

  predicate isSink(DataFlow::Node sink) {
    sink.asExpr().getType().stripType() instanceof CharIStream
  }

  predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    // By default we do not get flow from ConstructorFieldInit expressions to accesses
    // of the field in other member functions, so we add it explicitly here.
    exists(ConstructorFieldInit cfi, Field f |
      cfi.getTarget() = f and
      f.getType().stripType() instanceof CharIStream and
      node1.asExpr() = cfi.getExpr() and
      node2.asExpr() = f.getAnAccess()
    )
  }
}

private module CharIStreamConstructorCallUseFlow =
  TaintTracking::Global<CharIStreamConstructorCallUseConfig>;

/**
 * A `CharIStream` defined externally, and which therefore cannot be tracked as a source by taint tracking.
 *
 * For example, `std::cin`:
 * ```
 * extern std::istream cin;
 * ```
 */
class CharIStreamExternGlobal extends CharIStreamSource, GlobalOrNamespaceVariable {
  CharIStreamExternGlobal() { getType().stripType() instanceof CharIStream }

  override Expr getAUse() {
    // Defined externally, so assume any access is a use.
    result = getAnAccess()
  }
}

/**
 * A call which checks the error state of a `CharIStream`.
 */
class StreamErrorStateCheck extends FunctionCall {
  Expr checkedArg;

  StreamErrorStateCheck() {
    // Either a direct call
    checkedArg = this.(StreamErrorStateCheckDirectCall).getACheckedStream()
    or
    // Or a wrapper around an existing `StreamErrorStateCheck`
    exists(Function wrapper, int param, StreamErrorStateCheck wrappedErrorCheck |
      getTarget() = wrapper and
      DataFlow::localFlow(DataFlow::parameterNode(wrapper.getParameter(param)),
        DataFlow::exprNode(wrappedErrorCheck.getACheckedStream())) and
      checkedArg = getArgument(param)
    )
  }

  /** A checked stream */
  Expr getACheckedStream() { result = checkedArg }
}

query predicate problems(
  CharIStreamNumericExtractionOperatorCall numericExractionOpCall, string message
) {
  not isExcluded(numericExractionOpCall, getQuery()) and
  // No explicit error state checking after the numeric extraction operator call
  not exists(StreamErrorStateCheck errorStateCheck |
    // We use gvn here to find a call to `fail`
    globalValueNumber(errorStateCheck.getACheckedStream()) =
      globalValueNumber(numericExractionOpCall.getStream+()) and
    // Check occurs after the numeric extraction operation
    numericExractionOpCall.getASuccessor*() = errorStateCheck
    // Note: the fail and bad bits remain set until a call to `clear`
  ) and
  // If all source streams have a call to `exceptions` then we are safe.
  // We use forex here because if we find no sources (due to incomplete analysis), we should
  // assume that exceptions has _not_ been set
  not forex(CharIStreamSource source | numericExractionOpCall.getStream+() = source.getAUse() |
    exists(CharIStreamExceptionsCall exceptionsCall |
      exceptionsCall.getQualifier+() = source.getAUse() and
      // Both BadBit and FailBit must be enabled
      exceptionsCall.getAnEnabledFlag() instanceof IOState::BadBit and
      exceptionsCall.getAnEnabledFlag() instanceof IOState::FailBit
    |
      /*
       * The `exceptions` call should co-exist on a program path with the numeric extraction
       * operator call. We don't require that the `exceptions` call happens before the
       * extraction call (as calling `exceptions` after the extraction call will
       * trigger an exception if the error state is still set).
       */

      // Either there exists a common function which calls both `exceptions` and the numeric
      // extraction operator.
      exists(Function f |
        f.calls*(numericExractionOpCall.getEnclosingFunction()) and
        f.calls*(exceptionsCall.getEnclosingFunction())
      )
      or
      // Or the extraction operator call is in a member function of the class, and the `exceptions`
      // call is made from the constructor
      // Note: if the constructor and member function are called, this will be covered by the first
      //       part, but this is included to handle the case that they are never called in practice.
      exists(Class c |
        c.getAConstructor().calls*(exceptionsCall.getEnclosingFunction()) and
        c.getADerivedClass*().getAMemberFunction() = numericExractionOpCall.getEnclosingFunction()
      )
    )
  ) and
  message =
    "Error state not checked after call to string-to-numeric conversion function " +
      numericExractionOpCall.getTarget() + "."
}
