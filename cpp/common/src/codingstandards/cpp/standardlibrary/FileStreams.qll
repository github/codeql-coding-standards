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
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.dataflow.TaintTracking

/**
 * A `basic_fstream` like `std::fstream`
 */
class FileStream extends ClassTemplateInstantiation {
  FileStream() { this.getTemplate().hasQualifiedName("std", "basic_fstream") }
}

/**
 * A `basic_istream` like `std::istream`
 */
class IStream extends ClassTemplateInstantiation {
  IStream() { this.getTemplate().hasQualifiedName("std", "basic_istream") }
}

/**
 * A `basic_ostream` like `std::ostream`
 */
class OStream extends ClassTemplateInstantiation {
  OStream() { this.getTemplate().hasQualifiedName("std", "basic_ostream") }
}

/**
 * A call to a `FileStream` function.
 */
abstract class FileStreamFunctionCall extends FunctionCall {
  //returns the affected fstream
  abstract Expr getFStream();
}

predicate sameStreamSource(FileStreamFunctionCall a, FileStreamFunctionCall b) {
  exists(FileStreamSource c |
    c.getAUse() = a.getFStream() and
    c.getAUse() = b.getFStream()
  )
}

/**
 * Insertion `operator<<` and Extraction `operator>>` operators.
 */
class InsertionOperatorCall extends FileStreamFunctionCall {
  InsertionOperatorCall() { this.getTarget().(Operator).hasQualifiedName("std", "operator<<") }

  override Expr getFStream() {
    result = this.getQualifier()
    or
    result = this.getArgument(0) and this.getNumberOfArguments() = 2
  }
}

class ExtractionOperatorCall extends FileStreamFunctionCall {
  ExtractionOperatorCall() { this.getTarget().(Operator).hasQualifiedName("std", "operator>>") }

  override Expr getFStream() {
    result = this.getQualifier()
    or
    result = this.getArgument(0) and this.getNumberOfArguments() = 2
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
  CloseFunctionCall() {
    this.getTarget().hasQualifiedName("std", "basic_fstream", "close") or
    this.getTarget().hasGlobalName("fclose")
  }

  override Expr getFStream() {
    result = getQualifier()
    or
    result = this.getArgument(0) and this.getNumberOfArguments() = 1
  }
}

/**
 * A call to `std:basic_istream:seekg`, `std:basic_istream:seekg`,
 * `fflush`,`fseek`,`fsetpos`,`rewind` functions.
 */
class FileStreamPositioningCall extends FileStreamFunctionCall {
  FileStreamPositioningCall() {
    this.getTarget().hasQualifiedName("std", "basic_istream", "seekg") or
    this.getTarget().hasQualifiedName("std", "basic_ostream", "seekp")
  }

  override Expr getFStream() { result = getQualifier() }
}

/**
 * A call to `istream` or `ostream` functions.
 */
class IOStreamFunctionCall extends FileStreamFunctionCall {
  IOStreamFunctionCall() {
    this.getTarget().getDeclaringType() instanceof IStream
    or
    this.getTarget().getDeclaringType() instanceof OStream
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
 * A `FileStream` defined externally, and which therefore cannot be tracked as a source by taint tracking.
 */
class FileStreamExternGlobal extends FileStreamSource, GlobalOrNamespaceVariable {
  FileStreamExternGlobal() { this.getType().stripType() instanceof FileStream }

  override Expr getAUse() {
    // Defined externally, so assume any access is a use.
    result = getAnAccess()
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
