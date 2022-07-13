/**
 * @id cpp/autosar/unused-local-function
 * @name A0-1-3: Unused local function
 * @description Every function defined in an anonymous namespace, or static function with internal
 *              linkage, or private member function shall be used.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-1-3
 *       readability
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.DynamicCallGraph
import codingstandards.cpp.deadcode.UnusedFunctions

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
    // Not member functions, which don't have internal linkage
    not this instanceof MemberFunction and
    localFunctionType = "Anonymous namespace"
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

from LocalFunction unusedLocalFunction, string name
where
  not isExcluded(unusedLocalFunction, DeadCodePackage::unusedLocalFunctionQuery()) and
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
  // Get a printable name
  (
    if exists(unusedLocalFunction.getQualifiedName())
    then name = unusedLocalFunction.getQualifiedName()
    else name = unusedLocalFunction.getName()
  )
select unusedLocalFunction,
  unusedLocalFunction.getLocalFunctionType() + " function " + name +
    " is not statically called, or is in an unused template."
