/** A module to reason about side effects. */

import cpp
import semmle.code.cpp.dataflow.DataFlow
private import exceptions.ExceptionFlow
private import codingstandards.cpp.Expr
private import codingstandards.cpp.Variable
private import codingstandards.cpp.sideeffect.Customizations

/**
 * A side effect that captures external, global, and local side effects.
 * We use the following definitions:
 * - external - a modification to the environment of the application (e.g., writing output or writing a file.),
 * - global - a modification to the program state stored in variables with static storage duration,
 * - local - the modification and value computation of scalar variables (e.g., incrementing an integer with `i++`).
 */
class SideEffect extends Expr {
  SideEffect() {
    not this instanceof SideEffect::ExclusionRange and
    this instanceof SideEffect::Range
  }
}

/** A side effect that is not a local side effect. */
class NonLocalSideEffect extends SideEffect {
  NonLocalSideEffect() { not this instanceof LocalSideEffect }
}

/** A compiler generated side effect (typicall of the type ClassObjectSideEffect) that we want to exclude. */
private class CompilerGeneratedSideEffect extends SideEffect::ExclusionRange {
  CompilerGeneratedSideEffect() { this.isCompilerGenerated() }
}

/* A side effect occuring in a source file not part of the code repository (e.g. included standard header files) */
private class NonSourceSideEffect extends SideEffect::ExclusionRange {
  NonSourceSideEffect() { not exists(this.getFile().getRelativePath()) }
}

/** Gets an external, global, or local side effect produced directly by the expression `e` or an external/global side effect produced by a function reachable from the expression `e`. */
SideEffect getASideEffect(Expr e) {
  result = e.getAChild*()
  or
  exists(FunctionCall call |
    e.getAChild*() = call and result = getAnExternalOrAGlobalSideEffectInFunction(call.getTarget())
  )
}

/** Gets an external, global, or local side effect produced directly by `f` or an external/global side effect produced by a function reachable by `f`. */
SideEffect getASideEffectInFunction(Function f) {
  result.getEnclosingFunction() = f
  or
  exists(Function other |
    f.calls(other) and result = getAnExternalOrAGlobalSideEffectInFunction(other)
  )
}

/** A side effect that affects the program environment (e.g., writing a file). */
class ExternalSideEffect extends SideEffect {
  ExternalSideEffect() { this instanceof ExternalSideEffect::Range }
}

/** Holds if the expression `e` produces an external, global, or local (limited to expression `e`) side effect. */
predicate hasSideEffect(Expr e) { exists(getASideEffect(e)) }

/** Holds if the function `f` produces an external, global, or local (limited to function `f`) side effect. */
predicate hasSideEffectInFunction(Function f) { exists(getASideEffectInFunction(f)) }

/** Gets an external side effect produced by the expressoin `e`. */
ExternalSideEffect getAnExternalSideEffect(Expr e) {
  result = e.getAChild*()
  or
  exists(FunctionCall call |
    e.getAChild*() = call and result = getAnExternalSideEffectInFunction(call.getTarget())
  )
}

/** Gets an external side effect produced by the function `f`. */
ExternalSideEffect getAnExternalSideEffectInFunction(Function f) {
  result.getEnclosingFunction() = f
  or
  exists(Function other | f.calls(other) and result = getAnExternalSideEffectInFunction(other))
}

/** Holds if an external side effect is produced by the expression `e`. */
predicate hasExternalSideEffect(Expr e) { exists(getAnExternalSideEffect(e)) }

/** Holds if function `f` produces an external side effect. */
predicate hasExternalSideEffectInFunction(Function f) {
  exists(getAnExternalSideEffectInFunction(f))
}

/** Gets an external or global side effect produced by the expression `e`. */
SideEffect getAnExternalOrAGlobalSideEffect(Expr e) {
  result = getAnExternalSideEffect(e)
  or
  result = getAGlobalSideEffect(e)
}

/** Gets an external side effect produced by the function `f`. */
SideEffect getAnExternalOrGlobalSideEffectInFunction(Function f) {
  result = getAnExternalSideEffectInFunction(f)
  or
  result = getAGlobalSideEffectInFunction(f)
}

/** A side effect that affects global the state of the program. */
class GlobalSideEffect extends SideEffect {
  GlobalSideEffect() { this instanceof GlobalSideEffect::Range }
}

/** Gets a global side effect produced by the expression `e`. */
GlobalSideEffect getAGlobalSideEffect(Expr e) {
  result = e.getAChild*()
  or
  exists(FunctionCall call |
    e.getAChild*() = call and result = getAGlobalSideEffectInFunction(call.getTarget())
  )
}

/** Gets a global side effect produced by function `f`. */
GlobalSideEffect getAGlobalSideEffectInFunction(Function f) {
  result.getEnclosingFunction() = f
  or
  exists(Function other | f.calls(other) and result = getAGlobalSideEffectInFunction(other))
}

/** Holds if a global side effect is produced by the expression `e`. */
predicate hasGlobalSideEffect(Expr e) { exists(getAGlobalSideEffect(e)) }

/** Holds if function `f` produces a global side effect. */
predicate hasGlobalSideEffectInFunction(Function f) { exists(getAGlobalSideEffectInFunction(f)) }

/** Gets an external or global side effect produced by the expression `e`. */
SideEffect getAnExternalOrGlobalSideEffect(Expr e) {
  result = getAnExternalSideEffect(e)
  or
  result = getAGlobalSideEffect(e)
  or
  exists(FunctionCall call |
    e.getAChild*() = call and
    (
      result = getAnExternalSideEffectInFunction(call.getTarget())
      or
      result = getAGlobalSideEffectInFunction(call.getTarget())
    )
  )
}

/** Gets an external or global side effect produced by the function `f`. */
SideEffect getAnExternalOrAGlobalSideEffectInFunction(Function f) {
  result = getAnExternalSideEffectInFunction(f)
  or
  result = getAGlobalSideEffectInFunction(f)
}

/** Holds if function `f` produces an external or global side effect. */
predicate hasExternalOrGlobalSideEffectInFunction(Function f) {
  hasExternalSideEffectInFunction(f) or hasGlobalSideEffectInFunction(f)
}

/** Holds if function `op` is an modifying operator. */
private predicate modifyingOperator(Function op) {
  op.getName() in [
      "operator=", "operator+=", "operator-=", "operator*=", "operator/=", "operator%=",
      "operator^=", "operator&=", "operator|=", "operator>>=", "operator<<=", "operator++",
      "operator--"
    ]
}

/** Gets an effect directly applied to expression `base` or indirectly but changes the identity of `base`. */
Expr getAnEffect(Expr base) {
  // base cases
  result = base and
  base instanceof SideEffect
  or
  exists(Assignment a | a.getLValue() = base and result = a)
  or
  exists(CrementOperation c | c.getOperand() = base and result = c)
  or
  exists(FunctionCall c |
    c.getQualifier() = base and
    (modifyingOperator(c.getTarget()) or c instanceof DestructorCall) and
    result = c
  )
  or
  // recursive cases
  exists(ArrayExpr e | e.getArrayBase() = base | result = getAnEffect(e))
  or
  exists(VariableAccess va | va.getQualifier() = base | result = getAnEffect(va))
  or
  exists(PointerDereferenceExpr e | e.getOperand() = base | result = getAnEffect(e))
  or
  exists(CrementOperation c | c.getOperand() = base | result = getAnEffect(c))
  or
  // local alias analysis, assume alias when data flows to derived type (pointer/reference)
  // auto ptr = &base;
  exists(VariableAccess va, AddressOfExpr addressOf |
    not base = va and
    addressOf.getOperand() = base and
    DataFlow::localFlow(DataFlow::exprNode(addressOf), DataFlow::exprNode(va)) and
    va.getTarget().getUnspecifiedType() instanceof DerivedType
  |
    result = getAnEffect(va)
  )
  or
  // local alias analysis, initializing a reference variable with a base, potentially through a cast, such as `T* ptr = (T*)base`
  exists(VariableDeclarationEntry vde |
    vde.getVariable().getInitializer().getExpr() = base and
    vde.getVariable().getUnspecifiedType() instanceof DerivedType
  |
    result = getAnEffect(vde.getVariable().getAnAccess())
  )
  or
  // effects caused in reachable functions that receive a pointer/reference to our `base`.
  // void foo(int * ptr) {*ptr = 1;}
  // void bar(int * base) {
  //  foo(base);
  //}
  exists(FunctionCall call, int i |
    DataFlow::localFlow(DataFlow::exprNode(base), DataFlow::exprNode(call.getArgument(i)))
  |
    result = call.getTarget().getParameter(i).(AliasParameter).getAnEffect()
  )
}

/** A side effect happing as part of a subexpression that can result in unexpected/unspecified behavior when unsequenced. */
class LocalSideEffect extends SideEffect {
  LocalSideEffect() { this instanceof LocalSideEffect::Range }
}

/** Gets a local side effect produced by the expression `e`. */
LocalSideEffect getALocalSideEffect(Expr e) { result = e.getAChild*() }

/** An effect that changes the value of a variable. */
class VariableEffect extends Expr {
  VariableAccess va;
  Variable v;

  VariableEffect() { this = getAnEffect(va) and v = va.getTarget() }

  Variable getTarget() { result = v }

  VariableAccess getAnAccess() { result = va }

  // Holds if an effect modifies the identity of an object and not the entire object.
  predicate isPartial() {
    exists(VariableAccess qualifiedAccess | qualifiedAccess.getQualifier() = getAnAccess())
    or
    exists(ArrayExpr array | array.getArrayBase() = getAnAccess())
  }
}

class MemberVariableEffect extends Expr {
  MemberVariableEffect() {
    this instanceof VariableEffect
    or
    this instanceof ConstructorFieldInit
  }

  Variable getTarget() {
    result = this.(VariableEffect).getTarget()
    or
    result = this.(ConstructorFieldInit).getTarget()
  }
}

/** Gets a member variable effect in function `f` or a function reachable from `f`. */
MemberVariableEffect getAMemberVariableEffect(MemberFunction f) {
  result.getEnclosingFunction() = f and
  exists(MemberVariable v | v = result.getTarget() | v.getDeclaringType() = f.getDeclaringType())
  or
  exists(FunctionCall call, MemberFunction other |
    call.getQualifier() instanceof ThisExpr and
    call.getEnclosingFunction() = f and
    call.getTarget() = other and
    result = getAMemberVariableEffect(other)
  )
}

/** A pointer or reference parameter. */
class AliasParameter extends Parameter {
  AliasParameter() { this.getUnspecifiedType() instanceof DerivedType }

  /**
   * Gets an expression that modifies the object referenced by this parameter, but doesn't
   * track whether the reference is changed (i.e., the alias parameter is reassigned a different object).
   * This might attribute effects to an object that are performed on another object that happen after the pointer
   * is changed.
   */
  Expr getAnEffect() {
    exists(VariableAccess va | va.getTarget() = this |
      result = getAnEffect(va) and
      (
        // Any effect on a reference type
        this.getUnspecifiedType() instanceof ReferenceType
        or
        // Exclude effects that change the who we point to, since we care about changes to the referenced object.
        not result.(AssignExpr).getLValue() = va and
        not result.(CrementOperation).getOperand() = va
      )
    )
  }

  /** Holds if there exists an expresison that modifies the value referred by the parameter. */
  predicate isModified() { exists(getAnEffect()) }
}

module PathGraph {
  abstract class SideEffectTargetFunction extends Function { }

  predicate reachableFunctionWithSideEffect(Function f) {
    exists(SideEffectTargetFunction start |
      start.calls*(f) and
      exists(getASideEffectInFunction(f))
    )
  }

  newtype TSideEffectFlowNode =
    TFunctionNode(Function f) { reachableFunctionWithSideEffect(f) } or
    TCallNode(Call c) { reachableFunctionWithSideEffect(c.getTarget()) } or
    TSideEffectNode(SideEffect se) {
      exists(Function f | reachableFunctionWithSideEffect(f) and se = getASideEffectInFunction(f))
    }

  class SideEffectFlowNode extends TSideEffectFlowNode {
    Function asFunction() { this = TFunctionNode(result) }

    SideEffect asSideEffect() { this = TSideEffectNode(result) }

    Call asCall() { this = TCallNode(result) }

    string toString() {
      result = asFunction().toString()
      or
      result = asSideEffect().toString()
      or
      result = asCall().toString()
    }

    Location getLocation() {
      result = asFunction().getLocation()
      or
      result = asSideEffect().getLocation()
      or
      result = asCall().getLocation()
    }
  }

  query predicate edges(SideEffectFlowNode pred, SideEffectFlowNode succ) {
    exists(Function f, SideEffect se | se.getEnclosingFunction() = f |
      pred = TSideEffectNode(se) and succ = TFunctionNode(f)
    )
    or
    exists(Function f, SideEffect se, Call c | se.getEnclosingFunction() = f and c.getTarget() = f |
      pred = TFunctionNode(f) and succ = TCallNode(c)
    )
    or
    exists(Function f, SideEffect se, Call c, Function caller |
      se.getEnclosingFunction() = f and c.getTarget() = f and c.getEnclosingFunction() = caller
    |
      pred = TCallNode(c) and succ = TFunctionNode(caller)
    )
  }
}
