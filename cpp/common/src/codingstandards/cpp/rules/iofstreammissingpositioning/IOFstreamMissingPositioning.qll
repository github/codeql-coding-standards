/**
 * Provides a library which includes a `problems` predicate for reporting missing calls to
 * positioning functions `seekg` or `seekp` when alternately using the insertion and
 * extraction operators (`operator>>` and `operator<<`) on a file stream (`std::fstream`)
 */

import cpp
import semmle.code.cpp.dataflow.TaintTracking
import codingstandards.cpp.Exclusions
import codingstandards.cpp.standardlibrary.FileStreams

abstract class IOFstreamMissingPositioningSharedQuery extends Query { }

Query getQuery() { result instanceof IOFstreamMissingPositioningSharedQuery }

predicate sameStreamSource(FileStreamFunctionCall a, FileStreamFunctionCall b) {
  exists(FileStreamSource c |
    c.getAUse() = a.getFStream() and
    c.getAUse() = b.getFStream()
  )
}

predicate sameOperator(InExOperatorCall a, InExOperatorCall b) { a.getTarget() = b.getTarget() }

predicate oppositeOperator(InExOperatorCall a, InExOperatorCall b) { not sameOperator(a, b) }

/**
 * Insertion operator (`operator>>`) before extraction operator (`operator<<`)
 */
ControlFlowNode reachesInExOperator(InExOperatorCall op) {
  result = op
  or
  exists(ControlFlowNode mid |
    mid = reachesInExOperator(op) and
    result = mid.getAPredecessor() and
    //Stop recursion after first occurrence of the opposite operator
    not (oppositeOperator(mid, op) and sameStreamSource(mid, op)) and
    //Stop recursion on seek function calls
    not sameStreamSource(result.(SeekFunctionCall), op) and
    //Stop recursion on same operator
    not (sameOperator(result, op) and sameStreamSource(result, op))
  )
}

query predicate problems(
  InExOperatorCall fstOperator, string message, InExOperatorCall sndOperator,
  string sndOperatorDescription
) {
  not isExcluded(sndOperator, getQuery()) and
  not sameOperator(fstOperator, sndOperator) and
  sameStreamSource(fstOperator, sndOperator) and
  fstOperator = reachesInExOperator(sndOperator) and
  message = "Missing call to positioning function before $@." and
  sndOperatorDescription = sndOperator.toString()
}
