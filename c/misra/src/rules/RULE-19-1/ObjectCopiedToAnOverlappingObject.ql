/**
 * @id c/misra/object-copied-to-an-overlapping-object
 * @name RULE-19-1: An object shall not be copied to an overlapping object
 * @description An object shall not be copied to an overlapping object.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-19-1
 *       correctness
 *       external/misra/obligation/mandatory
 */

import cpp
import codingstandards.c.misra
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.dataflow.DataFlow

/**
 * Offset in bytes of a field access
 */
int getAccessByteOffset(FieldAccess fa) {
  not fa.getQualifier() instanceof FieldAccess and result = fa.getTarget().getByteOffset()
  or
  result = fa.getTarget().getByteOffset() + getAccessByteOffset(fa.getQualifier())
}

class OverlappingCopy extends Locatable {
  Expr src;
  Expr dst;

  OverlappingCopy() {
    this.(MacroInvocation).getMacroName() = "memcpy" and
    src = this.(MacroInvocation).getExpr().getChild(1) and
    dst = this.(MacroInvocation).getExpr().getChild(0)
    or
    this.(FunctionCall).getTarget().hasGlobalName("memcpy") and
    src = this.(FunctionCall).getArgument(1) and
    dst = this.(FunctionCall).getArgument(0)
  }

  Expr getSrc() { result = src }

  Expr getDst() { result = dst }

  Expr getBase(Expr e) {
    result =
      [
        e.(VariableAccess), e.(PointerAddExpr).getLeftOperand(),
        e.(AddressOfExpr).getOperand().(ArrayExpr).getArrayBase+(),
        e.(AddressOfExpr).getOperand().(ValueFieldAccess).getQualifier+()
      ]
  }

  int getOffset(Expr e) {
    result =
      [
        e.(PointerAddExpr).getRightOperand().getValue().toInt(),
        e.(AddressOfExpr).getOperand().(ArrayExpr).getArrayOffset().getValue().toInt(),
        getAccessByteOffset(e.(AddressOfExpr).getOperand()),
      ]
    or
    e instanceof VariableAccess and result = 0
  }

  int getCount() {
    result =
      upperBound([this.(MacroInvocation).getExpr().getChild(2), this.(FunctionCall).getArgument(2)])
  }

  // source and destination overlap
  predicate overlaps() {
    globalValueNumber(this.getBase(src)) = globalValueNumber(this.getBase(dst)) and
    exists(int dstStart, int dstEnd, int srcStart, int srcEnd |
      dstStart = this.getOffset(dst) and
      dstEnd = dstStart + this.getCount() - 1 and
      srcStart = this.getOffset(src) and
      srcEnd = srcStart + this.getCount() - 1 and
      (
        srcStart >= dstStart and srcEnd <= dstEnd
        or
        srcStart <= dstStart and srcEnd > dstStart
        or
        srcStart < dstEnd and srcEnd >= dstStart
      ) and
      // Exception 1: exact overlap and compatible type
      not (
        srcStart = dstStart and
        srcEnd = dstEnd and
        this.getBase(src).getUnspecifiedType() = this.getBase(dst).getUnspecifiedType()
      )
    )
  }
}

from OverlappingCopy copy
where
  not isExcluded(copy, Contracts7Package::objectCopiedToAnOverlappingObjectQuery()) and
  copy.overlaps()
select copy, "The object to copy $@ overlaps the object to copy $@.", copy.getSrc(), "from",
  copy.getDst(), "to"
