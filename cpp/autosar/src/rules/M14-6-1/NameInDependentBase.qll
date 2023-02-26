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
 * There is a `MemberFunction` in parent class with same name
 * as a `FunctionCall` that exists in a child `MemberFunction`
 */
FunctionCall parentMemberFunctionCall(Class child, Class parent) {
  exists(MemberFunction parentFunction, Function other |
    not other = parentFunction and
    parent.getAMember() = parentFunction and
    other.getName() = parentFunction.getName() and
    result = other.getACallToThisFunction() and
    result.getEnclosingFunction() = child.getAMemberFunction()
  )
}

/**
 * There is a `MemberFunction` in parent class with same name
 * as a `FunctionAccess` that exists in a child `MemberFunction`
 */
FunctionAccess parentMemberFunctionAccess(Class child, Class parent) {
  exists(MemberFunction parentFunction, Function other |
    not other = parentFunction and
    parent.getAMember() = parentFunction and
    other.getName() = parentFunction.getName() and
    result = other.getAnAccess() and
    result.getEnclosingFunction() = child.getAMemberFunction()
  )
}

/**
 * There is a `MemberVariable` in parent class with same name
 * as a `VariableAccess` that exists in a child `MemberFunction`
 */
Access parentMemberAccess(Class child, Class parent) {
  exists(MemberVariable parentMember, Variable other |
    not other = parentMember and
    parent.getAMemberVariable() = parentMember and
    other.getName() = parentMember.getName() and
    result = other.getAnAccess() and
    result.getEnclosingFunction() = child.getAMemberFunction()
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
