import cpp
private import codingstandards.cpp.StdNamespace
private import codingstandards.cpp.types.Templates
private import semmle.code.cpp.dataflow.new.DataFlow

Namespace getTemplateParameterNamespace(TypeTemplateParameter param) {
  exists(Declaration decl |
    param = decl.(TemplateClass).getATemplateArgument() or
    param = decl.(TemplateVariable).getATemplateArgument() or
    param = decl.(TemplateFunction).getATemplateArgument()
  |
    result = decl.getNamespace()
  )
}

class PredicateType extends TypeTemplateParameter {
  PredicateType() {
    this.getName().matches(["%Compare%", "%Predicate%"]) and
    getTemplateParameterNamespace(this) instanceof StdNS
  }

  Type getASubstitutedType(Substitution sub) { result = sub.getSubstitutedTypeForParameter(this) }
}

class PredicateFunctionObject extends Class {
  PredicateType pred;
  Function operator;
  Substitution sub;

  PredicateFunctionObject() {
    this = pred.getASubstitutedType(sub) and
    operator.getDeclaringType() = this and
    operator.getName() = "operator()"
  }

  PredicateType getPredicateType() { result = pred }

  Function getCallOperator() { result = operator }

  Substitution getSubstitution() { result = sub }
}

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

  PredicateType getPredicateType() { result = pred }
}
