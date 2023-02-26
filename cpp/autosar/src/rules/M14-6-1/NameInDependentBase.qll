import cpp
import codingstandards.cpp.autosar

/**
 * Gets a dependent base type of the given template class.
 *
 * This returns the `TemplateClass` for the base type, rather than the `ClassTemplateInstantiation`,
 * as the instantiation does not appear to include any member declarations.
 */
TemplateClass getADependentBaseType(TemplateClass t) {
  exists(ClassTemplateInstantiation baseType |
    baseType = t.getABaseClass() and
    // Base type depends on at least one of the template parameters of class t
    baseType.getATemplateArgument() = t.getATemplateArgument() and
    // Return the template itself
    result = baseType.getTemplate()
  )
}

/**
 * Gets a function call in `TemplateClass` `t` where the target function name exists in a dependent
 * base type and the function does not call that function.
 */
FunctionCall parentMemberFunctionCall(TemplateClass t) {
  exists(TemplateClass dependentBaseType, MemberFunction dependentTypeFunction, Function target |
    dependentBaseType = getADependentBaseType(t) and
    not target = dependentTypeFunction and
    dependentBaseType.getAMember() = dependentTypeFunction and
    target.getName() = dependentTypeFunction.getName() and
    result = target.getACallToThisFunction() and
    result.getEnclosingFunction() = t.getAMemberFunction()
  )
}

/**
 * There is a `MemberFunction` in parent class with same name
 * as a `FunctionAccess` that exists in a child `MemberFunction`
 */
FunctionAccess parentMemberFunctionAccess(TemplateClass t) {
  exists(TemplateClass dependentBaseType, MemberFunction dependentTypeFunction, Function target |
    dependentBaseType = getADependentBaseType(t) and
    not target = dependentTypeFunction and
    dependentBaseType.getAMember() = dependentTypeFunction and
    target.getName() = dependentTypeFunction.getName() and
    result = target.getAnAccess() and
    result.getEnclosingFunction() = t.getAMemberFunction()
  )
}

/**
 * There is a `MemberVariable` in parent class with same name
 * as a `VariableAccess` that exists in a child `MemberFunction`
 */
Access parentMemberAccess(TemplateClass t) {
  exists(
    TemplateClass dependentBaseType, MemberVariable dependentTypeMemberVariable, Variable target
  |
    dependentBaseType = getADependentBaseType(t) and
    not target = dependentTypeMemberVariable and
    dependentBaseType.getAMemberVariable() = dependentTypeMemberVariable and
    target.getName() = dependentTypeMemberVariable.getName() and
    result = target.getAnAccess() and
    result.getEnclosingFunction() = t.getAMemberFunction()
  )
}

/**
 * A `NameQualifiableElement` without a name qualifier
 */
predicate missingNameQualifier(NameQualifiableElement element) {
  not exists(NameQualifier q | q = element.getNameQualifier())
}

/**
 * heuristics: do not care about:
 *   compiler generated calls
 *   superclass constructor use, in constructor delegation
 */
predicate isCustomExcluded(Expr fn) {
  fn.isCompilerGenerated() or
  fn instanceof ConstructorDirectInit or
  fn.(FunctionCall).getTarget() instanceof Operator
}
