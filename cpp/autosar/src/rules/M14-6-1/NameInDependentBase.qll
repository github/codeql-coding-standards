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
  exists(TemplateClass dependentBaseType, MemberFunction parentFunction, Function other |
    dependentBaseType = getADependentBaseType(t) and
    not other = parentFunction and
    dependentBaseType.getAMember() = parentFunction and
    other.getName() = parentFunction.getName() and
    result = other.getACallToThisFunction() and
    result.getEnclosingFunction() = t.getAMemberFunction()
  )
}

/**
 * There is a `MemberFunction` in parent class with same name
 * as a `FunctionAccess` that exists in a child `MemberFunction`
 */
FunctionAccess parentMemberFunctionAccess(TemplateClass t) {
  exists(TemplateClass dependentBaseType, MemberFunction parentFunction, Function other |
    dependentBaseType = getADependentBaseType(t) and
    not other = parentFunction and
    dependentBaseType.getAMember() = parentFunction and
    other.getName() = parentFunction.getName() and
    result = other.getAnAccess() and
    result.getEnclosingFunction() = t.getAMemberFunction()
  )
}

/**
 * There is a `MemberVariable` in parent class with same name
 * as a `VariableAccess` that exists in a child `MemberFunction`
 */
Access parentMemberAccess(TemplateClass t) {
  exists(TemplateClass dependentBaseType, MemberVariable parentMember, Variable other |
    dependentBaseType = getADependentBaseType(t) and
    not other = parentMember and
    dependentBaseType.getAMemberVariable() = parentMember and
    other.getName() = parentMember.getName() and
    result = other.getAnAccess() and
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
