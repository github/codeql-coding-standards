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

/** Checks if a Function's address was taken. */
predicate addressBeenTaken(Function unusedFunction) {
  exists(FunctionAccess fa | fa.getTarget() = unusedFunction)
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
    exists(string name |
      not isExcluded(unusedLocalFunction, Config::getQuery()) and
      // No static or dynamic call target for this function
      not unusedLocalFunction = getTarget(_) and
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
        functionFromInstantiatedTemplate = getTarget(_)
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
      // Get a printable name
      (
        if exists(unusedLocalFunction.getQualifiedName())
        then name = unusedLocalFunction.getQualifiedName()
        else name = unusedLocalFunction.getName()
      ) and
      message =
        unusedLocalFunction.getLocalFunctionType() + " function " + name +
          " is not statically called, or is in an unused template."
    )
  }
}
