import cpp

private newtype TSubstitution =
  TClassSubstitution(ClassTemplateInstantiation cti) or
  TFunctionSubstitution(FunctionTemplateInstantiation fti) or
  TVariableSubstitution(VariableTemplateInstantiation vti)

/**
 * A class to facilitate working with template substitutions, especially since templates may be a
 * `TemplateClass`, `TemplateFunction`, or `TemplateVariable`, which complicates their usage.
 *
 * A `Substitution` in particular refers to an instantiation of that template of some kind, and
 * allows analysis of which parameters were substituted with which types in that instatiation.
 */
class Substitution extends TSubstitution {
  ClassTemplateInstantiation asClassSubstitution() { this = TClassSubstitution(result) }

  FunctionTemplateInstantiation asFunctionSubstitution() { this = TFunctionSubstitution(result) }

  VariableTemplateInstantiation asVariableSubstitution() { this = TVariableSubstitution(result) }

  /**
   * Get the nth template parameter type of the template that is being substituted.
   *
   * For example, in `std::vector<int>`, the 0th template parameter is `typename T`.
   */
  TypeTemplateParameter getTemplateParameter(int index) {
    result = this.asClassSubstitution().getTemplate().getTemplateArgument(index) or
    result = this.asFunctionSubstitution().getTemplate().getTemplateArgument(index) or
    result = this.asVariableSubstitution().getTemplate().getTemplateArgument(index)
  }

  /**
   * Get the type that is substituting the nth template parameter in this substitution.
   *
   * For example, in `std::vector<int>`, the 0th substituted type is `int`.
   */
  Type getSubstitutedType(int index) {
    result = this.asClassSubstitution().getTemplateArgument(index) or
    result = this.asFunctionSubstitution().getTemplateArgument(index) or
    result = this.asVariableSubstitution().getTemplateArgument(index)
  }

  /**
   * Get the type that is substituting the given template parameter in this substitution.
   *
   * For example, in `std::vector<int>`, this predicate matches the given type `int` with the type
   * parameter `typename T`.
   */
  Type getSubstitutedTypeForParameter(TypeTemplateParameter param) {
    exists(int idx |
      this.getTemplateParameter(idx) = param and
      result = this.getSubstitutedType(idx)
    )
  }

  string toString() {
    result = this.asClassSubstitution().toString() or
    result = this.asFunctionSubstitution().toString() or
    result = this.asVariableSubstitution().toString()
  }

  /**
   * Get a `Locatable` that represents a where this substitution was declared in the source code.
   *
   * The result may be a `TypeMention`, `Call`, etc. depending on the kind of template and how it is
   * being used, but it handles the various template cases for you.
   *
   * Note that this instantiation may have been declared in multiple places.
   */
  Locatable getASubstitutionSite() {
    result.(TypeMention).getMentionedType() = this.asClassSubstitution()
    or
    result.(Call).getTarget() = this.asFunctionSubstitution()
    or
    result.(FunctionAccess).getTarget() = this.asFunctionSubstitution()
    or
    result.(VariableAccess).getTarget() = this.asVariableSubstitution()
  }
}
