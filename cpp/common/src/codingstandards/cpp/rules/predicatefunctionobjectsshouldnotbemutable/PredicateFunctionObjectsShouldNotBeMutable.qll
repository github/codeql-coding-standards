/**
 * Provides a library with a `problems` predicate for the following issue:
 * "Non-static data members or captured values of predicate function objects
 * that are state related to this object's identity shall not be copied.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.SideEffect
import codingstandards.cpp.sideeffect.DefaultEffects

abstract class PredicateFunctionObjectsShouldNotBeMutableSharedQuery extends Query { }

Query getQuery() { result instanceof PredicateFunctionObjectsShouldNotBeMutableSharedQuery }

/** A function object type as defined in [function.objects] */
class FunctionObjectType extends Type {
  FunctionObjectType() {
    this instanceof FunctionPointerType
    or
    this.(Class).getAMember() instanceof CallOperator
    or
    this.(Class).getAMember().(ConversionOperator).getDestType().getUnderlyingType() instanceof
      FunctionPointerType
    or
    this instanceof Closure // The type returned by `getType` of a `LambdaExpression`
  }
}

/** A function object as defined in [function.objects] */
class FunctionObject extends Expr {
  FunctionObject() { this.getUnderlyingType() instanceof FunctionObjectType }

  private Class getAClassType() { result = getUnspecifiedType() }

  Function getTarget() {
    // Function pointers
    this.getUnderlyingType() instanceof FunctionPointerType and
    (
      result = this.(FunctionAccess).getTarget()
      or
      exists(FunctionAccess fa |
        DataFlow::localFlow(DataFlow::exprNode(fa), DataFlow::exprNode(this.(VariableAccess)))
      |
        result = fa.getTarget()
      )
    )
    or
    // Function objects (i.e., implement `operator()` or a conversion to a function pointer.)
    exists(Class c, CallOperator op |
      c = getAClassType() and
      c.getAMember() = op
    |
      result = op
    )
    or
    exists(Class c, ConversionOperator op, FunctionAccess fa |
      c = getAClassType() and
      c.getAMember() = op and
      DataFlow::localFlow(DataFlow::exprNode(fa),
        DataFlow::exprNode(op.getBlock().getAStmt().(ReturnStmt).getExpr()))
    |
      result = fa.getTarget()
    )
    or
    result = this.(LambdaExpression).getLambdaFunction()
  }
}

/** A function object that wraps another function object (e.g., std::ref) */
class WrappedFunctionObject extends FunctionObject {
  FunctionObject subject;

  WrappedFunctionObject() { this.(Call).getAnArgument() = subject }

  override Function getTarget() { result = subject.getTarget() }
}

abstract class CopyImperviousMutablePredicateWrapper extends WrappedFunctionObject { }

private class StdRefCall extends CopyImperviousMutablePredicateWrapper {
  StdRefCall() {
    exists(Function ref | ref.hasQualifiedName("std", "ref") | ref.getACallToThisFunction() = this)
  }
}

/** A call operator */
class CallOperator extends Operator {
  CallOperator() { this.getName() = "operator()" }
}

/** A callable type as defined in [func.def] */
class CallableType extends Type {
  CallableType() {
    this instanceof FunctionObjectType
    or
    this instanceof PointerToMemberType
  }
}

/** A callable as defined in [func.def] */
class Callable extends Expr {
  Callable() { this.getUnderlyingType() instanceof CallableType }

  Function getTarget() { this.(FunctionObject).getTarget() = result }

  /** Holds if type `t` can be converted to a boolean according to [conv.bool] */
  private predicate canConvertToBool(Type t) {
    // A prvalue of arithmetic
    t instanceof IntegralType
    or
    // unscoped enumeration
    t instanceof Enum and not t instanceof ScopedEnum
    or
    // pointer, or pointer to member type
    t instanceof PointerToMemberType
    or
    t instanceof PointerType
  }

  /**
   * Holds if the callable might be a predicate with a predicate being:
   * - A function returning a value that can be implicitly converted to a boolean.
   * - A function that accepts at least one parameter.
   *
   * Initially we had a more specific definition where the return value of a callable
   * must be derived from a parameter, but this is problematic for two reasons.
   *
   * 1. Indirect taint flows. A tainted parameter `p` indirectly influences the return value.
   * ```
   * if (p % 2 == 0)
   *   return true;
   * return false
   * ```
   *
   * 2. Taint sanitization. Our taint propagation is optimized for security and sanitizes the taint when
   * the influence of an attacker is deemed insufficient. For example, in the following snippet taint propagates
   * from `p` to `p % 2`, but not from `p % 2` to `p % 2 == 0`/
   * ```
   * ...
   * return p % 2 == 0;
   * ```
   */
  predicate isMaybeAPredicate() {
    exists(Function f | f = getTarget() |
      canConvertToBool(f.getType()) and
      f.getNumberOfParameters() > 0
    )
  }
}

class Algorithm extends Function {
  Algorithm() {
    exists(TemplateFunction tf, HeaderFile h |
      h.getBaseName() = "algorithm" and
      this = tf.getAnInstantiation() and
      (
        // LLVM declares algorithms in the algorithm header.
        h.getADeclaration() = tf.getADeclaration()
        or
        // GCC declares algorithms in a bits header.
        exists(HeaderFile other |
          h.getAnIncludedFile() = other and
          other.getAbsolutePath().regexpMatch(".*/bits/stl_algo(base)*.h")
        |
          other.getADeclaration() = tf.getADeclaration()
        )
      )
    )
  }
}

VariableAccess getNonStaticMemberWrite(MemberFunction f) {
  exists(MemberVariable v |
    result.getEnclosingFunction() = f and
    result.getTarget() = v and
    v.getDeclaringType() = f.getDeclaringType() and
    not v.isStatic()
  |
    result.isModified()
  )
  or
  exists(MemberFunction other | f.calls(other) and f.getDeclaringType() = other.getDeclaringType() |
    result = getNonStaticMemberWrite(other)
  )
}

query predicate problems(
  FunctionCall algorithmCall, string message, Callable functionObject, string functionObjectDesc,
  Expr stateWrite, string stateWriteDesc
) {
  exists(Function f |
    not isExcluded(functionObject, getQuery()) and
    algorithmCall.getAnArgument() = functionObject and
    algorithmCall.getTarget() instanceof Algorithm and
    f = functionObject.getTarget() and
    functionObject.isMaybeAPredicate() and
    not functionObject instanceof CopyImperviousMutablePredicateWrapper and
    (
      stateWrite = getAnExternalOrGlobalSideEffectInFunction(f) or
      stateWrite = getNonStaticMemberWrite(f)
    ) and
    message = "The predicate $@ argument that should not be mutable mutates the $@." and
    functionObjectDesc = "function object" and
    stateWriteDesc = "state"
  )
}
