/**
 * @id cpp/autosar/static-or-thread-local-objects-non-constant-init
 * @name A3-3-2: Static and thread-local objects shall be constant-initialized
 * @description Non-const global and static variables are difficult to read and maintain.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-3-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * Holds if `e` is a full expression or `AggregateLiteral` in the initializer of a
 * `StaticStorageDurationVariable`.
 *
 * Although `AggregateLiteral`s are expressions according to our model, they are not considered
 * expressions from the perspective of the standard. Therefore, we should consider components of
 * aggregate literals within static initializers to also be full expressions.
 */
private predicate isFullExprOrAggregateInStaticInitializer(Expr e) {
  exists(StaticStorageDurationVariable var | e = var.getInitializer().getExpr())
  or
  isFullExprOrAggregateInStaticInitializer(e.getParent().(AggregateLiteral))
}

/**
 * Holds if `e` is a non-constant full expression in a static initializer, for the given `reason`
 * and `reasonElement`.
 */
private predicate nonConstantFullExprInStaticInitializer(
  Expr e, Element reasonElement, string reason
) {
  isFullExprOrAggregateInStaticInitializer(e) and
  if e instanceof AggregateLiteral
  then
    // If this is an aggregate literal, we apply this recursively
    nonConstantFullExprInStaticInitializer(e.getAChild(), reasonElement, reason)
  else (
    // Otherwise we check this component to determine if it is constant
    not (
      e.getFullyConverted().isConstant() or
      e.(Call).getTarget().isConstexpr() or
      e.(VariableAccess).getTarget().isConstexpr()
    ) and
    reason = "uses a non-constant element in the initialization" and
    reasonElement = e
  )
}

/**
 * A `ConstructorCall` that does not represent a constant initializer for an object according to
 * `[basic.start.init]`.
 *
 * In addition to identifying `ConstructorCall`s which are not constant initializers, this also
 * provides an explanatory "reason" for why this constructor is not considered to be a constant
 * initializer.
 */
predicate isNotConstantInitializer(ConstructorCall cc, Element reasonElement, string reason) {
  // Must call a constexpr constructor
  not cc.getTarget().isConstexpr() and
  reason =
    "calls the " + cc.getTarget().getName() + "(..) constructor which is not marked as constexpr" and
  reasonElement = cc
  or
  // And all arguments must either be constant, or themselves call constexpr constructors
  cc.getTarget().isConstexpr() and
  exists(Expr arg | arg = cc.getAnArgument() |
    isNotConstantInitializer(arg, reasonElement, reason)
    or
    not arg instanceof ConstructorCall and
    not arg.getFullyConverted().isConstant() and
    not arg.(Call).getTarget().isConstexpr() and
    not arg.(VariableAccess).getTarget().isConstexpr() and
    reason = "includes a non constant " + arg.getType() + " argument to a constexpr constructor" and
    reasonElement = arg
  )
}

/**
 * Identifies if a `StaticStorageDurationVariable` is not constant initialized according to
 * `[basic.start.init]`.
 */
predicate isNotConstantInitialized(
  StaticStorageDurationVariable v, string reason, Element reasonElement
) {
  if v.getInitializer().getExpr() instanceof ConstructorCall
  then
    // (2.2) if initialized by a constructor call, then that constructor call must be a constant
    // initializer for the variable to be constant initialized
    isNotConstantInitializer(v.getInitializer().getExpr(), reasonElement, reason)
  else
    // (2.3) If it is not initialized by a constructor call, then it must be the case that every full
    // expr in the initializer is a constant expression or that the object was "value initialized"
    // but without a constructor call. For value initialization, there are two non-constructor call
    // cases to consider:
    //
    //  1. The object was zero initialized - in which case, the extractor does not include a
    //     constructor call - instead, it has a blank aggregate literal, or no initializer.
    //  2. The object is an array, which will be initialized by an aggregate literal.
    //
    // In both cases it is sufficient for us to find a non-constant full expression in the static
    // initializer
    nonConstantFullExprInStaticInitializer(v.getInitializer().getExpr(), reasonElement, reason)
}

from StaticStorageDurationVariable staticOrThreadLocalVar, string reason, Element reasonElement
where
  not isExcluded(staticOrThreadLocalVar,
    InitializationPackage::staticOrThreadLocalObjectsNonConstantInitQuery()) and
  isNotConstantInitialized(staticOrThreadLocalVar, reason, reasonElement) and
  // Uninstantiated templates may have initializers that are not semantically complete
  not staticOrThreadLocalVar.isFromUninstantiatedTemplate(_)
select staticOrThreadLocalVar.getInitializer(),
  "Static or thread-local object " + staticOrThreadLocalVar.getName() +
    " is not constant initialized because it $@.", reasonElement, reason
