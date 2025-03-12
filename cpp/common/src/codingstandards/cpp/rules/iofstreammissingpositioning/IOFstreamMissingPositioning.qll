/**
 * Provides a library which includes a `problems` predicate for reporting missing calls to
 * positioning functions `seekg` or `seekp` when alternately using the insertion and
 * extraction operators (`operator>>` and `operator<<`) on a file stream (`std::fstream`)
 */

import cpp
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.Exclusions
import codingstandards.cpp.standardlibrary.FileStreams
import codingstandards.cpp.standardlibrary.FileAccess

abstract class IOFstreamMissingPositioningSharedQuery extends Query { }

Query getQuery() { result instanceof IOFstreamMissingPositioningSharedQuery }

/**
 * A Class modelling calls to file read and write functions.
 */
abstract class ReadWriteCall extends FunctionCall {
  abstract string getAccessDirection();

  abstract Expr getFStream();
}

class ReadFunctionCall extends ReadWriteCall {
  ReadFunctionCall() {
    this instanceof FileReadFunctionCall or
    this instanceof ExtractionOperatorCall
  }

  override string getAccessDirection() { result = "read" }

  override Expr getFStream() {
    result = this.(FileReadFunctionCall).getFileExpr() or
    result = this.(ExtractionOperatorCall).getFStream()
  }
}

class WriteFunctionCall extends ReadWriteCall {
  WriteFunctionCall() {
    this instanceof FileWriteFunctionCall or
    this instanceof InsertionOperatorCall
  }

  override string getAccessDirection() { result = "write" }

  override Expr getFStream() {
    result = this.(FileWriteFunctionCall).getFileExpr() or
    result = this.(InsertionOperatorCall).getFStream()
  }
}

pragma[inline]
predicate sameSource(FunctionCall a, FunctionCall b) {
  sameStreamSource(a, b) or
  sameFileSource(a, b)
}

bindingset[a, b]
predicate sameAccessDirection(ReadWriteCall a, ReadWriteCall b) {
  a.getAccessDirection() = b.getAccessDirection()
}

bindingset[a, b]
predicate oppositeAccessDirection(ReadWriteCall a, ReadWriteCall b) {
  not sameAccessDirection(a, b)
}

/**
 * A write operation reaching a read and vice versa
 * without intervening file positioning calls.
 */
ControlFlowNode reachesInExOperator(ReadWriteCall op) {
  result = op
  or
  exists(ControlFlowNode mid |
    mid = reachesInExOperator(op) and
    result = mid.getAPredecessor() and
    //Stop recursion after first occurrence of the opposite operator
    not (oppositeAccessDirection(mid, op) and sameStreamSource(mid, op)) and
    //Stop recursion on positioning function calls
    not sameSource(result.(FileStreamPositioningCall), op) and
    not sameSource(result.(FilePositioningFunctionCall), op) and
    //Stop recursion on same operator
    not (sameAccessDirection(result, op) and sameSource(result, op))
  )
}

query predicate problems(
  ReadWriteCall snd, string message, ReadWriteCall fst, string fstOperatorDescription
) {
  not isExcluded(snd, getQuery()) and
  not sameAccessDirection(fst, snd) and
  sameSource(fst, snd) and
  fst = reachesInExOperator(snd) and
  message = "Missing call to positioning function before $@." and
  fstOperatorDescription = snd.toString()
}
