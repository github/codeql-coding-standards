/**
 * A library for handling "predicate" types, which are function parameters in the standard library.
 *
 * For example, `std::sort` takes a predicate as its third argument, and `std::set` takes a
 * predicate as its second template parameter. Predicates are always template parameters, and we
 * can identify them by their name -- this is what MISRA expects us to do.
 */

import cpp
private import codingstandards.cpp.StdNamespace
private import codingstandards.cpp.ast.Templates
private import codingstandards.cpp.types.Templates
private import semmle.code.cpp.dataflow.new.DataFlow

/**
 * A "predicate" type parameter as defined by MISRA, which is a standard library function named
 * "Compare" or "Predicate" or "BinaryPredicate" in the standard library.
 *
 * To be more widely useful, we match more flexibly on the name, as `_Compare` is also common, etc.
 *
 * To get a particular `Type` that is _used_ as a predicate type, see `getASubstitutedType()`,
 * rather than the type parameter itself, see `getASubstitutedType()`.
 */
class PredicateType extends TypeTemplateParameter {
  PredicateType() {
    this.getName().matches(["%Compare%", "%Predicate%"]) and
    getTemplateParameterNamespace(this) instanceof StdNS
  }

  /**
   * Get a type that is used (anywhere, via some substitution) as this predicate type parameter.
   *
   * For example, `std::sort(..., ..., [](int a, int b) { return a < b; })` creates a `Closure`
   * type, and substitutes that closure type for the predicate type parameter of `std::sort`.
   */
  Type getASubstitutedType(Substitution sub) { result = sub.getSubstitutedTypeForParameter(this) }
}

/**
 * A class type that has been substituted for a predicate type parameter, and has an `operator()`
 * member function.
 *
 * For example, the closure type in `std::sort(..., ..., [](int a, int b) { return a < b; })` is a
 * `PredicateFunctionObject`, and so is any `std::less<int>` that is used as a predicate type
 * parameter, etc.
 *
 * This does not cover function pointer types, as these are not class types.
 */
class PredicateFunctionObject extends Class {
  PredicateType pred;
  Function operator;
  Substitution sub;

  PredicateFunctionObject() {
    this = pred.getASubstitutedType(sub) and
    operator.getDeclaringType() = this and
    operator.getName() = "operator()"
  }

  /**
   * Get the predicate type parameter that this function object is being substituted for.
   */
  PredicateType getPredicateType() { result = pred }

  /**
   * Get the `operator()` function that this function object defines. This is the function that will
   * be invoked and essentially defines the predicate behavior.
   */
  Function getCallOperator() { result = operator }

  /**
   * Get the `Substitution` object that makes this type a `PredicateFunctionObject`.
   *
   * This is a particular instantiation of some template that contains a predicate type parameter,
   * which is substituted by this type in that instantiation. The `Substitution` object may refer
   * to a `TemplateClass`, `TemplateVariable`, or `TemplateFunction`.
   */
  Substitution getSubstitution() { result = sub }
}

/**
 * Gets a function access where the purpose of that access is to pass the accessed function as a
 * predicate argument to a standard library template.
 *
 * For example, in `std::sort(..., ..., myCompare)`, where `myCompare` is a function, then
 * `myCompare` will be converted into a function pointer and that function pointer will be used as
 * a predicate in that `std::sort` call.
 *
 * This is more complex to identify than `PredicateFunctionObject` because the addressee of the
 * function pointer is not necessarily statically known.
 */
class PredicateFunctionPointerUse extends FunctionAccess {
  Expr functionPointerArgument;
  FunctionCall templateFunctionCall;
  FunctionTemplateInstantiation instantiation;
  Substitution sub;
  PredicateType pred;
  Parameter parameter;
  int index;

  PredicateFunctionPointerUse() {
    functionPointerArgument = templateFunctionCall.getArgument(index) and
    templateFunctionCall.getTarget() = instantiation and
    parameter = instantiation.getParameter(index) and
    sub.asFunctionSubstitution() = instantiation and
    parameter.getType() = sub.getSubstitutedTypeForParameter(pred) and
    exists(DataFlow::Node func, DataFlow::Node arg |
      func.asExpr() = this and
      arg.asExpr() = functionPointerArgument and
      DataFlow::localFlow(func, arg)
    )
  }

  /**
   * Get the predicate type parameter that this function pointer is being substituted for.
   */
  PredicateType getPredicateType() { result = pred }
}
