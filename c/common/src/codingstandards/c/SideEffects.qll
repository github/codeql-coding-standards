/** A module that implements the side effects described in 5.1.2.3 section 1 of the ISO/IEC 9899:2011 standard. */

import cpp
import semmle.code.cpp.security.FileWrite
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.Customizations

private class ModifyingLocalObject extends LocalSideEffect::Range {
  ModifyingLocalObject() {
    this.(AssignExpr).getLValue().(VariableAccess).getTarget() instanceof LocalScopeVariable
    or
    this.(CrementOperation).getOperand().(VariableAccess).getTarget() instanceof LocalScopeVariable
  }
}

private class ModifyingGlobalObject extends GlobalSideEffect::Range {
  ModifyingGlobalObject() {
    this.(AssignExpr).getLValue().(VariableAccess).getTarget() instanceof GlobalVariable
    or
    this.(CrementOperation).getOperand().(VariableAccess).getTarget() instanceof GlobalVariable
  }
}

private class VolatileAccess extends GlobalSideEffect::Range, VariableAccess {
  VolatileAccess() {
    this.getTarget().isVolatile() and
    // Exclude value computation of an lvalue expression soley used to determine the identity
    // of the object. As noted in the footnote of 6.5.16 point 3 it is implementation dependend
    // whether the value of the assignment expression derived from the left operand after the assignment
    // is determined by reading the object. We assume it is not for assignments that are a child of an
    // expression statement because the value is not used and is required for the compliant MISRA-C:2012 case:
    // `extern volatile int v; v = v & 0x80;`
    not exists(ExprStmt s | s.getExpr().(Assignment).getLValue() = this)
  }
}

private class ExternalFunctionCall extends GlobalSideEffect::Range, FunctionCall {
  ExternalFunctionCall() { not exists(this.getTarget().getBlock()) }
}

private class FileWriteEffect extends ExternalSideEffect::Range, FileWrite { }
