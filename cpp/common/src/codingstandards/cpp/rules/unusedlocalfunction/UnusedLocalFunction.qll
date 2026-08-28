/**
 * Provides a configurable module UnusedLocalFunction with a `problems` predicate
 * for the following issue:
 * Unused functions may indicate a coding error or require maintenance; functions that
 * are unused with certain visibility have no effect on the program and should be
 * removed.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.DynamicCallGraph
import codingstandards.cpp.deadcode.UnusedFunctions

/**
 * Checks if an overloaded function of
 * the function passed in the arguments, is called.
 */
predicate overloadedFunctionIsCalled(Function unusedFunction) {
  exists(Function f | f = unusedFunction.getAnOverload() and f = getTarget(_))
}

/**
 * Holds if `fn` is the target of some call, either statically or according to the
 * dynamic call graph.
 *
 * `DynamicCallGraph::getTarget()` resolves a virtual call to the functions that may
 * actually run, i.e. the overriding implementations. A pure virtual function has no
 * body, so it is never a viable dispatch target and is therefore *never* returned by
 * `getTarget()` -- even when it is unambiguously named by a call, as in the
 * non-virtual interface (NVI) idiom where a public member calls a private pure
 * virtual. The additional static `FunctionCall.getTarget()` disjunct recovers exactly
 * that case: the callee as written in the source.
 */
predicate functionIsCalled(Function fn) {
  fn = getTarget(_)
  or
  // The statically named callee, which the dynamic call graph drops for calls that
  // dispatch to an override (notably pure virtual functions, which have no body).
  exists(FunctionCall fc | fc.getTarget() = fn)
}

/** Checks if a Function's address was taken. */
predicate addressBeenTaken(Function unusedFunction) {
  exists(FunctionAccess fa | fa.getTarget() = unusedFunction)
}

/**
 * Holds if some member of the class `c` has at least one concrete instantiation anywhere in the
 * database.
 *
 * If this holds for the declaring type of a member function `fn`, the class template is genuinely
 * "alive" (used with a concrete type somewhere), and the fact that `fn` itself was never
 * instantiated is real evidence that it is unused: for a member function to lack a concrete
 * instantiation while sibling members do have one, it must never have been called from any of
 * those sibling bodies.
 *
 * `pragma[noinline]` keeps this a standalone relation of arity one. Inlined into the caller, the
 * join orderer loses the fact that `c` is functionally determined and materialises the full
 * (member, sibling) cross product per class before projecting it away, which is quadratic in the
 * size of the largest class.
 */
pragma[noinline]
private predicate classHasAnyInstantiatedMember(Class c) {
  exists(Function sibling, Function siblingInstantiation |
    sibling.getDeclaringType() = c and
    siblingInstantiation.isConstructedFrom(sibling)
  )
}

/**
 * Holds if `fn` is a function from an uninstantiated template for which no concrete
 * instantiation exists anywhere in the database, and no other member of the same
 * class-template pattern is instantiated either.
 *
 * When a class template is never instantiated with a concrete type in the analyzed
 * compilation units, Clang never elaborates a body for its member functions, so
 * `Call`/`FunctionCall` targets within that pattern's own text cannot be resolved by
 * `DynamicCallGraph::getTarget()` or `VirtualDispatch`, even for calls between sibling members
 * of the very same class (e.g. a constructor calling a private helper). This is common for
 * generic "plumbing" library code (CRTP-style wrappers, etc.)
 * that is only ever instantiated by downstream consumers outside of this codebase. In that
 * situation we have no visibility at all into the call graph, so we conservatively treat the
 * function as "used" (out of scope for this analysis) rather than report it as dead code.
 *
 * We only do this when *no* sibling member of the class pattern has an instantiation either
 * (see `classHasAnyInstantiatedMember`): if some sibling *is* instantiated, the class is
 * genuinely used, and `fn` lacking an instantiation is real (not merely missing) evidence that
 * it is unused.
 */
predicate hasNoVisibleInstantiation(Function fn) {
  // Restricted to class-template members: a standalone function template that is never
  // instantiated anywhere is genuinely dead code, and detecting that does not suffer from the
  // "sibling member of the same class" ambiguity this predicate is designed for.
  fn instanceof MemberFunction and
  fn.isFromUninstantiatedTemplate(_) and
  not exists(Function instantiation | instantiation.isConstructedFrom(fn)) and
  not classHasAnyInstantiatedMember(fn.getDeclaringType())
}

/** A `Function` nested in an anonymous namespace. */
class AnonymousNamespaceFunction extends Function {
  AnonymousNamespaceFunction() { getNamespace().getParentNamespace*().isAnonymous() }
}

/**
 * A function which is "local" to a particular scope or translation unit.
 */
class LocalFunction extends UnusedFunctions::UsableFunction {
  string localFunctionType;

  LocalFunction() {
    this.(MemberFunction).isPrivate() and
    localFunctionType = "Private member"
    or
    // A function in an anonymous namespace (which is deduced to have internal linkage)
    this instanceof AnonymousNamespaceFunction and
    not this instanceof MemberFunction and
    localFunctionType = "Anonymous namespace"
    or
    // Class members in anonymous namespaces also have internal linkage.
    this instanceof AnonymousNamespaceFunction and
    this instanceof MemberFunction and
    localFunctionType = "Anonymous namespace class member"
    or
    // Static functions with internal linkage
    this.isStatic() and
    // Member functions never have internal linkage
    not this instanceof MemberFunction and
    // Functions in anonymous namespaces automatically have the "static" specifier added by the
    // extractor. We therefore excluded them from this case, and instead report them in the
    // anonymous namespace, as we don't know whether the "static" specifier was explicitly
    // provided by the user.
    not this instanceof AnonymousNamespaceFunction and
    localFunctionType = "Static"
  }

  /** Gets the type of local function. */
  string getLocalFunctionType() { result = localFunctionType }
}

signature module UnusedLocalFunctionConfigSig {
  Query getQuery();
}

module UnusedLocalFunction<UnusedLocalFunctionConfigSig Config> {
  query predicate problems(LocalFunction unusedLocalFunction, string message) {
    not isExcluded(unusedLocalFunction, Config::getQuery()) and
    // No static or dynamic call target for this function
    not functionIsCalled(unusedLocalFunction) and
    // If this is a TemplateFunction or an instantiation of a template, then only report it as unused
    // if all other instantiations of the template are unused
    not exists(
      Function functionFromUninstantiatedTemplate, Function functionFromInstantiatedTemplate
    |
      // `unusedLocalFunction` is a template instantiation from `functionFromUninstantiatedTemplate`
      unusedLocalFunction.isConstructedFrom(functionFromUninstantiatedTemplate)
      or
      // `unusedLocalFunction` is from an uninstantiated template
      unusedLocalFunction = functionFromUninstantiatedTemplate
    |
      // There exists an instantiation which is called
      functionFromInstantiatedTemplate.isConstructedFrom(functionFromUninstantiatedTemplate) and
      functionIsCalled(functionFromInstantiatedTemplate)
    ) and
    // A function is defined as "used" if any one of the following holds true:
    // - It's an explicitly deleted functions e.g. =delete
    // - It's annotated as "[[maybe_unused]]"
    // - It's part of an overloaded set and any one of the overloaded instance
    //   is called.
    // - It's an operand of an expression in an unevaluated context.
    not unusedLocalFunction.isDeleted() and
    not unusedLocalFunction.getAnAttribute().getName() = "maybe_unused" and
    not overloadedFunctionIsCalled(unusedLocalFunction) and
    not addressBeenTaken(unusedLocalFunction) and
    // We have no visibility into the call graph of a template that is never instantiated
    // anywhere in the database, so we cannot reliably tell it is unused.
    not hasNoVisibleInstantiation(unusedLocalFunction) and
    message =
      unusedLocalFunction.getLocalFunctionType() + " function " + unusedLocalFunction.getName() +
        " is not statically called, or is in an unused template."
  }
}
