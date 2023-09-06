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

module Namespaces {
  private int getNamespaceDepth(Namespace n) {
    n instanceof GlobalNamespace and result = 0
    or
    result = getNamespaceDepth(n.getParentNamespace()) + 1
  }

  private Namespace getNamespaceIndex(Namespace n, int i) {
    getNamespaceDepth(n) = i and result = n
    or
    getNamespaceDepth(n) > i and result = getNamespaceIndex(n.getParentNamespace(), i)
  }

  pragma[inline]
  Namespace getCommonNamespace(Namespace n1, Namespace n2) {
    exists(int i |
      result = getNamespaceIndex(n1, i) and
      result = getNamespaceIndex(n2, i) and
      not getNamespaceIndex(n1, i + 1) = getNamespaceIndex(n2, i + 1)
    )
  }

  /**
   * Gets the enclosing namespace of a using directive.
   *
   * Using directives can only appear in block scope or namespace scope.
   */
  Namespace getEnclosingNamespace(UsingDirectiveEntry ude) {
    exists(Element parentScope | parentScope = ude.getParentScope() |
      result = parentScope
      or
      result = parentScope.(BlockStmt).getEnclosingFunction().getNamespace()
    )
  }

  /**
   * Gets the namespace under which the imported names will be visible.
   *
   * Names will be visible in the closest common namespace.
   */
  Namespace getVisibleNamespace(UsingDirectiveEntry ude) {
    result = getCommonNamespace(ude.getNamespace(), getEnclosingNamespace(ude))
  }

  Namespace getAnAliasedNamespace(Namespace n) {
    exists(UsingDirectiveEntry ude | result = getVisibleNamespace(ude) and n = ude.getNamespace())
  }
}

pragma[noinline]
private predicate candGetAnOverloadNonMember(string name, Namespace namespace, Function f) {
  f.getName() = name and
  (
    f.getNamespace() = namespace
    or
    Namespaces::getAnAliasedNamespace(f.getNamespace()) = namespace
  ) and
  not exists(f.getDeclaringType())
}

pragma[noinline]
private predicate candGetAnOverloadMember(string name, Class declaringType, Function f) {
  f.getName() = name and
  f.getDeclaringType() = declaringType
}

/**
 * Gets an approximation of the overload set for the function `f`.
 */
Function getAnOverload(Function f) {
  (
    // If this function is declared in a class, only consider other
    // functions from the same class.
    exists(string name, Class declaringType |
      candGetAnOverloadMember(name, declaringType, f) and
      candGetAnOverloadMember(name, declaringType, result)
    )
    or
    // Conversely, if this function is not
    // declared in a class, only consider other functions not declared in a
    // class.
    exists(string name, Namespace namespace |
      candGetAnOverloadNonMember(name, namespace, f) and
      candGetAnOverloadNonMember(name, namespace, result)
    )
  ) and
  result != f and
  // Instantiations and specializations don't participate in overload
  // resolution.
  not (
    f instanceof FunctionTemplateInstantiation or
    result instanceof FunctionTemplateInstantiation
  ) and
  not (
    f instanceof FunctionTemplateSpecialization or
    result instanceof FunctionTemplateSpecialization
  )
}

/**
 * Checks if a function call exists to the function
 * passed in the arguments.
 */
predicate isCalled(Function unusedFunction) { unusedFunction = getTarget(_) }

/**
 * Checks if an overloaded function of
 * the function passed in the arguments, is called.
 */
predicate overloadedFunctionIsCalled(Function unusedFunction) {
  exists(Function f | f = getAnOverload(unusedFunction) and isCalled(f))
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
  )
select unusedLocalFunction,
  unusedLocalFunction.getLocalFunctionType() + " function " + name +
    " is not statically called, or is in an unused template."
