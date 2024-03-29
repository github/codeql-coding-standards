/**
 * Provides a `DataFlow2` module, which is a copy of the `DataFlow` module. Use
 * this class when data-flow configurations must depend on each other. Two
 * classes extending `DataFlow::Configuration` should never depend on each
 * other, but one of them should instead depend on a
 * `DataFlow2::Configuration`, a `DataFlow3::Configuration`, or a
 * `DataFlow4::Configuration`.
 *
 * See `semmle.code.cpp.dataflow.DataFlow` for the full documentation.
 *
 * NOTE: This is copied from `codeql/cpp-all` to avoid deprecation warnings
 * that cannot be avoided in tests.
 */

import cpp

/**
 * DEPRECATED: Use `semmle.code.cpp.dataflow.new.DataFlow2` instead.
 *
 * Provides classes for performing local (intra-procedural) and
 * global (inter-procedural) data flow analyses.
 */
module DataFlow2 {
  import semmle.code.cpp.dataflow.internal.DataFlowImpl2
}
