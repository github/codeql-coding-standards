import cpp

/**
 * A predicate to simplify getting a namespace for a template parameter, since
 * `TemplateParameterType`'s `getNamespace()` has no result, and `enclosingElement()` has no result,
 * and there are multiple cases to navigate to work around this.
 */
Namespace getTemplateParameterNamespace(TypeTemplateParameter param) {
  exists(Declaration decl |
    param = decl.(TemplateClass).getATemplateArgument() or
    param = decl.(TemplateVariable).getATemplateArgument() or
    param = decl.(TemplateFunction).getATemplateArgument()
  |
    result = decl.getNamespace()
  )
}
