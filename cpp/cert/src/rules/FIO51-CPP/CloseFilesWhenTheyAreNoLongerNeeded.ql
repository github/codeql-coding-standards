/**
 * @id cpp/cert/close-files-when-they-are-no-longer-needed
 * @name FIO51-CPP: Close files when they are no longer needed
 * @description Failing to properly close files may allow an attacker to exhaust system resources.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/fio51-cpp
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.standardlibrary.CStdLib
import codingstandards.cpp.standardlibrary.FileStreams
import codingstandards.cpp.standardlibrary.Exceptions

/**
 * Model calls that terminate the program execution
 */
class ExplicitTerminationCall extends FunctionCall {
  ExplicitTerminationCall() {
    getTarget() instanceof StdTerminate or
    getTarget() instanceof StdQuickExit or
    getTarget() instanceof StdAbort or
    getTarget() instanceof Std_Exit
  }
}

/**
 * Model accesses to the fstream underlying file buffer
 */
predicate filebufAccess(ControlFlowNode node, FileStreamSource fss) {
  node = fss or
  node.(OpenFunctionCall).getFStream() = fss.getAUse() or
  //insertion or extraction operator calls
  node.(InsertionOperatorCall).getFStream() = fss.getAUse() or
  node.(ExtractionOperatorCall).getFStream() = fss.getAUse() or
  //methods inherited from istream or ostream
  node.(IOStreamFunctionCall).getFStream() = fss.getAUse()
}

/**
 * Paths reaching program termination without a call to close
 */
ControlFlowNode reachesTermination(ExplicitTerminationCall tc, FileStreamSource fss) {
  result = tc
  or
  exists(ControlFlowNode mid |
    mid = reachesTermination(tc, fss) and
    result = mid.getAPredecessor() and
    not filebufAccess(mid, fss) and
    //Stop recursion on close or destructor
    not result.(CloseFunctionCall).getFStream() = fss.getAUse() and
    not result.(DestructorCall).getQualifier() = fss.getAUse()
  )
}

from FileStreamSource fss, ControlFlowNode node, ExplicitTerminationCall tc
where
  not isExcluded(tc, IOPackage::closeFilesWhenTheyAreNoLongerNeededQuery()) and
  node = reachesTermination(tc, fss) and
  filebufAccess(node, fss)
select tc, "The execution terminates without closing the `fstream` last accessed in $@.", node,
  node.toString()
