/**
 * @id c/cert/incorrect-null-termination-of-readlink
 * @name POS30-C: Use the readlink() function properly
 * @description The readlink() function does not null terminate or leave a character at the end of
 *              the buffer argument, and must be handled properly.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/pos30-c
 *       correctness
 *       security
 *       external/cert/obligation/rule
 */

import cpp
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.Dominance
import semmle.code.cpp.controlflow.Guards
import codingstandards.c.cert
import codingstandards.cpp.StdFunctionOrMacro

predicate isValidSize(Expr size) { size.(SubExpr).getAnOperand().getValue().toInt() = 1 }

AssignExpr getNullTermination(ReadlinkCall readlink) {
  exists(AssignExpr assign, ArrayExpr arrayExpr, Expr arrayBase, Expr arrayOffset |
    assign.getLValue() = arrayExpr and
    arrayExpr.getArrayBase() = arrayBase and
    arrayExpr.getArrayOffset() = arrayOffset and
    DataFlow::localFlow(DataFlow::exprNode(readlink.getExpr()), DataFlow::exprNode(arrayOffset)) and
    DataFlow::localFlow(DataFlow::definitionByReferenceNodeFromArgument(readlink.getBufferArg()),
      DataFlow::exprNode(arrayBase)) and
    result = assign
  )
}

predicate isErrorChecked(ReadlinkCall readlink, GuardCondition check, BasicBlock block) {
  exists(Expr sizeExpr |
    DataFlow::localFlow(DataFlow::exprNode(readlink.getExpr()), DataFlow::exprNode(sizeExpr)) and
    (
      check.ensuresLt(sizeExpr, 0, block, false)
      or
      check.ensuresEq(sizeExpr, -1, block, false)
    )
  )
}

predicate isErrorCheckedBeforeNullTermination(ReadlinkCall readlink, GuardCondition check) {
  isErrorChecked(readlink, check, getNullTermination(readlink).getBasicBlock())
}

predicate usedBeforeNullTermination(ReadlinkCall readlink, Expr use, Expr nullTerm) {
  nullTerm = getNullTermination(readlink) and
  DataFlow::localFlow(DataFlow::definitionByReferenceNodeFromArgument(readlink.getBufferArg()),
    DataFlow::exprNode(use)) and
  not strictlyDominates(nullTerm, use) and
  not use.getParent+() = nullTerm
}

from
  ReadlinkCall readlink, string message, Element extra1, string extraString1, Element extra2,
  string extraString2
where
  not isExcluded(readlink.getElement(), IO5Package::incorrectNullTerminationOfReadlinkQuery()) and
  (
    not isValidSize(readlink.getSizeArg()) and
    message = "Call to readlink() with size argument that may not leave room for a null terminator." and
    extra1 = readlink.getElement() and
    extra2 = readlink.getElement() and
    extraString1 = "" and
    extraString2 = ""
  )
  or
  not exists(getNullTermination(readlink)) and
  message =
    "Call to readlink() not followed by an assignment that ensures a null terminated result string." and
  extra1 = readlink.getElement() and
  extra2 = readlink.getElement() and
  extraString1 = "" and
  extraString2 = ""
  or
  not isErrorChecked(readlink, _, _) and
  message = "Call to readlink() not followed by a check to result error code." and
  extra1 = readlink.getElement() and
  extra2 = readlink.getElement() and
  extraString1 = "" and
  extraString2 = ""
  or
  not isErrorCheckedBeforeNullTermination(readlink, extra2) and
  message = "Buffer passed to readlink() is $@ by result value before the result value is $@." and
  extra1 = getNullTermination(readlink) and
  isErrorChecked(readlink, extra2, _) and
  extraString1 = "null terminated" and
  extraString2 = "error checked"
  or
  usedBeforeNullTermination(readlink, extra1, extra2) and
  message = "Buffer passed to readlink() is $@ before $@." and
  extraString1 = "used" and
  extraString2 = "null terminaton is added"
select readlink.getElement(), message, extra1, extraString1, extra2, extraString2
