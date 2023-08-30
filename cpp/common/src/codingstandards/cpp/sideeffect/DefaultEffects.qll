import cpp
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.Customizations
private import codingstandards.cpp.Allocations
private import codingstandards.cpp.Expr
private import codingstandards.cpp.Variable
private import semmle.code.cpp.security.FileWrite

/** A function call that performs an IO operation and thus exhibts an external side effect. */
private class IOFunctionCall extends FunctionCall, ExternalSideEffect::Range {
  IOFunctionCall() { this instanceof BasicOStreamCall or this instanceof FileWrite }
}

private class ResourceReleaseCall extends ExternalSideEffect::Range {
  ResourceReleaseCall() { freeExpr(this, _, _) }
}

private class DirectStaticStorageDurationVariableModification extends VariableEffect,
  GlobalSideEffect::Range
{
  DirectStaticStorageDurationVariableModification() {
    this.getTarget() instanceof StaticStorageDurationVariable
  }
}

private class ConstructorFieldInitEffect extends GlobalSideEffect::Range, ConstructorFieldInit { }

private class AliasVariableModification extends VariableEffect, GlobalSideEffect::Range {
  AliasVariableModification() { this.getTarget() instanceof AliasParameter }
}

private class ViolatileAccess extends ExternalSideEffect::Range, VariableAccess {
  ViolatileAccess() { this.getTarget().isVolatile() }
}

/** Holds if the scalar variable is incremented or decremented using a prefix or postfix operation. */
private predicate hasScalarSideEffects(ConstituentExpr e, ScalarVariable v) {
  exists(VariableAccess va |
    va.getTarget() = v and
    e.(CrementOperation).getAnOperand() = va
  )
}

private class LocalScalarValueModificationAndValueComputation extends LocalSideEffect::Range {
  LocalScalarValueModificationAndValueComputation() {
    exists(ScalarVariable v |
      v instanceof LocalVariable and
      hasScalarSideEffects(this, v)
    )
  }
}

private class PointerCrementOperation extends CrementOperation, LocalSideEffect::Range {
  PointerCrementOperation() {
    exists(VariableAccess va | va.getType() instanceof PointerType | this.getAnOperand() = va)
  }
}

private class ReturnedReferenceModificationAndValueComputation extends LocalSideEffect::Range {
  ReturnedReferenceModificationAndValueComputation() {
    exists(FunctionCall call |
      this.(CrementOperation).getOperand() = call and
      call.getType().getUnderlyingType().getUnspecifiedType() instanceof ReferenceType
    )
  }
}
