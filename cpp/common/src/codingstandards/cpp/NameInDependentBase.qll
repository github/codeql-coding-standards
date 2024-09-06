import cpp

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
 * Helper predicate that ensures we do not join on function pairs by name early on, as that creates
 * a large dataset on big databases with lots of name duplication.
 */
pragma[nomagic]
private FunctionCall helper_functioncall(
  TemplateClass t, TemplateClass dependentBaseType, Function target, string name
) {
  dependentBaseType = getADependentBaseType(t) and
  // The target of the call is not declared in the dependent base type
  not target.getDeclaringType() = dependentBaseType and
  result = target.getACallToThisFunction() and
  result.getEnclosingFunction() = t.getAMemberFunction() and
  name = target.getName()
}

/**
 * Gets a function call in `TemplateClass` `t` where the target function name exists in a dependent
 * base type and the call is to a function that is not declared in the dependent base type.
 */
FunctionCall getConfusingFunctionCall(
  TemplateClass t, string name, Function target, MemberFunction dependentTypeFunction
) {
  exists(TemplateClass dependentBaseType |
    result = helper_functioncall(t, dependentBaseType, target, name) and
    // The dependentTypeFunction is declared on the dependent base type
    dependentBaseType.getAMember() = dependentTypeFunction and
    // And has the same name as the target of the function call in the child
    name = dependentTypeFunction.getName()
  )
}

/**
 * Helper predicate that ensures we do not join on function pairs by name early on, as that creates
 * a large dataset on big databases with lots of name duplication.
 */
pragma[nomagic]
private FunctionAccess helper_functionaccess(
  TemplateClass t, TemplateClass dependentBaseType, Function target, string name
) {
  dependentBaseType = getADependentBaseType(t) and
  // The target of the access is not declared in the dependent base type
  not target.getDeclaringType() = dependentBaseType and
  result = target.getAnAccess() and
  result.getEnclosingFunction() = t.getAMemberFunction() and
  name = target.getName()
}

/**
 * Gets a function access in `TemplateClass` `t` where the target function name exists in a dependent
 * base type and the access is to a function declared outside the dependent base type.
 */
FunctionAccess getConfusingFunctionAccess(
  TemplateClass t, string name, Function target, MemberFunction dependentTypeFunction
) {
  exists(TemplateClass dependentBaseType |
    result = helper_functionaccess(t, dependentBaseType, target, name) and
    dependentBaseType.getAMember() = dependentTypeFunction and
    name = dependentTypeFunction.getName()
  )
}

/**
 * Helper predicate that ensures we do not join on variable pairs by name early on, as that creates
 * a large dataset on big databases with lots of name duplication.
 */
pragma[nomagic]
private VariableAccess helper_memberaccess(
  TemplateClass t, TemplateClass dependentBaseType, Variable target, string name
) {
  dependentBaseType = getADependentBaseType(t) and
  // The target of the access is not declared in the dependent base type
  not target.getDeclaringType() = dependentBaseType and
  result = target.getAnAccess() and
  result.getEnclosingFunction() = t.getAMemberFunction() and
  name = target.getName() and
  // The target is not a local variable, which isn't subject to confusion
  not target instanceof LocalScopeVariable
}

/**
 * Gets a memmber access in `TemplateClass` `t` where the target member name exists in a dependent
 * base type and the access is to a variable declared outside the dependent base type.
 */
VariableAccess getConfusingMemberVariableAccess(
  TemplateClass t, string name, Variable target, MemberVariable dependentTypeMemberVariable
) {
  exists(TemplateClass dependentBaseType |
    result = helper_memberaccess(t, dependentBaseType, target, name) and
    dependentBaseType.getAMemberVariable() = dependentTypeMemberVariable and
    name = dependentTypeMemberVariable.getName()
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
