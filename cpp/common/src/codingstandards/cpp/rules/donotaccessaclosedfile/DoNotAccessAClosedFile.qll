/**
 * Provides a library which includes a `problems` predicate for reporting
 * access to closed files
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.standardlibrary.FileAccess
import semmle.code.cpp.controlflow.SubBasicBlocks

abstract class DoNotAccessAClosedFileSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotAccessAClosedFileSharedQuery }

class ClosedFileAccessSubBasicBlock extends SubBasicBlockCutNode {
  ClosedFileAccessSubBasicBlock() {
    this instanceof VariableAccess or
    this instanceof AssignExpr or
    this instanceof FunctionCall
  }
}

pragma[inline]
predicate accessSameVariable(VariableAccess va1, VariableAccess va2) {
  va1.getTarget() = va2.getTarget()
}

SubBasicBlock followsFileClose(SubBasicBlock source, Expr closedFile) {
  result = source
  or
  exists(SubBasicBlock mid |
    mid = followsFileClose(source, closedFile) and
    result = mid.getASuccessor() and
    //Stop recursion on reassignment of closedFile
    not accessSameVariable(result.(AssignExpr).getLValue(), closedFile)
  )
}

// the argument of a call to function `fclose(FILE*)` is subsequently accessed
predicate closedFileAccess(Expr closedFile, Expr fileAccess) {
  exists(DataFlow::DefinitionByReferenceNode def |
    def.asDefiningArgument() = closedFile and
    DataFlow::localFlow(def, DataFlow::exprNode(fileAccess.(VariableAccess)))
  )
}

query predicate problems(
  Expr fileAccess, string message, FunctionCall closeFC, string closeFCDescription
) {
  not isExcluded(fileAccess, getQuery()) and
  exists(Expr closedFile |
    fcloseCall(closeFC, closedFile) and
    fileAccess = followsFileClose(closeFC, closedFile) and
    (
      // implicit access to closed stdio/stderr/stdout
      fileAccess.(ImplicitFileAccess).getFileExpr() = closedFile
      or
      // explicit access to a closed FILE object
      closedFileAccess(closedFile, fileAccess)
    ) and
    message = "Access of closed file" + closedFile + " which was closed at $@" and
    closeFCDescription = "this location."
  )
}
