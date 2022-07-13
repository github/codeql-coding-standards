/**
 * A module for modeling classes and functions related to file streams in the C++ Standard Library.
 *
 * A file stream is a template instantiation of `std::basic_fstream`.
 * This module identifies such instantiations as `FileStream`s. It also models various features of
 * file streams, including:
 *  - Calls to various `fstream` functions (`open()`,`close()`, `seekp()` etc.).
 *  - Calls to `fstream` insertion and extraction operators (`operator<<`, `operator>>`).
 *  - Sources of file stream objects `FileStreamSource`
 */

import cpp
import semmle.code.cpp.dataflow.TaintTracking

/**
 * A `basic_fstream` like `std::fstream`
 */
class FileStream extends ClassTemplateInstantiation {
  FileStream() { getTemplate().hasQualifiedName("std", "basic_fstream") }
}

/**
 * A `basic_istream` like `std::istream`
 */
class IStream extends ClassTemplateInstantiation {
  IStream() { getTemplate().hasQualifiedName("std", "basic_istream") }
}

/**
 * A `basic_ostream` like `std::ostream`
 */
class OStream extends ClassTemplateInstantiation {
  OStream() { getTemplate().hasQualifiedName("std", "basic_ostream") }
}

/**
 * A call to a `FileStream` function.
 */
abstract class FileStreamFunctionCall extends FunctionCall {
  //returns the affected fstream
  abstract Expr getFStream();
}

/**
 * Insertion `operator<<` and Extraction `operator>>` operators.
 */
abstract class InExOperator extends Operator { }

class InsertionOperator extends InExOperator {
  InsertionOperator() { hasQualifiedName("std", "operator<<") }
}

class ExtractionOperator extends InExOperator {
  ExtractionOperator() { hasQualifiedName("std", "operator>>") }
}

/**
 * A call to a `FileStream` insertion or extractor operator.
 */
class InExOperatorCall extends FileStreamFunctionCall {
  InExOperatorCall() { getTarget() instanceof InExOperator }

  /**
   * Get the `FileStream` expression on which the operator is called.
   */
  override Expr getFStream() {
    result = getQualifier()
    or
    result = getArgument(0) and getNumberOfArguments() = 2
  }
}

/**
 * A call to `open` functions.
 */
class OpenFunctionCall extends FileStreamFunctionCall {
  OpenFunctionCall() { getTarget().hasQualifiedName("std", "basic_fstream", "open") }

  override Expr getFStream() { result = getQualifier() }
}

/**
 * A call to `close` functions.
 */
class CloseFunctionCall extends FileStreamFunctionCall {
  CloseFunctionCall() { getTarget().hasQualifiedName("std", "basic_fstream", "close") }

  override Expr getFStream() { result = getQualifier() }
}

/**
 * A call to `seekg` or `seekp` functions.
 */
class SeekFunctionCall extends FileStreamFunctionCall {
  SeekFunctionCall() {
    getTarget().hasQualifiedName("std", "basic_istream", "seekg")
    or
    getTarget().hasQualifiedName("std", "basic_ostream", "seekp")
  }

  override Expr getFStream() { result = getQualifier() }
}

/**
 * A call to `istream` or `ostream` functions.
 */
class IOStreamFunctionCall extends FileStreamFunctionCall {
  IOStreamFunctionCall() {
    getTarget().getDeclaringType() instanceof IStream
    or
    getTarget().getDeclaringType() instanceof OStream
  }

  override Expr getFStream() {
    result = getQualifier()
    or
    result = getArgument(0) and getNumberOfArguments() = 2
  }
}

/**
 * A source of a `FileStream` object.
 */
abstract class FileStreamSource extends Element {
  /** A use of this source stream. */
  abstract Expr getAUse();
}

/**
 * A `FileStream` created by a `ConstructorCall`.
 */
class FileStreamConstructorCall extends FileStreamSource, Expr {
  FileStreamConstructorCall() {
    this.(ConstructorCall).getTarget().getDeclaringType().getABaseClass*() instanceof FileStream
  }

  override Expr getAUse() {
    any(FileStreamConstructorCallUseConfig c)
        .hasFlow(DataFlow::exprNode(this), DataFlow::exprNode(result))
  }
}

/**
 * A global taint tracking configuration to track `FileStream` uses in the program.
 */
private class FileStreamConstructorCallUseConfig extends TaintTracking::Configuration {
  FileStreamConstructorCallUseConfig() { this = "FileStreamUse" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof FileStreamConstructorCall
  }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr().getType().stripType() instanceof FileStream
  }

  override predicate isAdditionalTaintStep(DataFlow::Node node1, DataFlow::Node node2) {
    // By default we do not get flow from ConstructorFieldInit expressions to accesses
    // of the field in other member functions, so we add it explicitly here.
    exists(ConstructorFieldInit cfi, Field f |
      cfi.getTarget() = f and
      f.getType().stripType() instanceof FileStream and
      node1.asExpr() = cfi.getExpr() and
      node2.asExpr() = f.getAnAccess()
    )
  }
}

/**
 * A `FileStream` defined externally, and which therefore cannot be tracked as a source by taint tracking.
 */
class FileStreamExternGlobal extends FileStreamSource, GlobalOrNamespaceVariable {
  FileStreamExternGlobal() { getType().stripType() instanceof FileStream }

  override Expr getAUse() {
    // Defined externally, so assume any access is a use.
    result = getAnAccess()
  }
}
