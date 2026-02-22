import cpp

private newtype TSubstitution =
  TClassSubstitution(ClassTemplateInstantiation cti) or
  TFunctionSubstitution(FunctionTemplateInstantiation fti) or
  TVariableSubstitution(VariableTemplateInstantiation vti)

class Substitution extends TSubstitution {
  ClassTemplateInstantiation asClassSubstitution() { this = TClassSubstitution(result) }

  FunctionTemplateInstantiation asFunctionSubstitution() { this = TFunctionSubstitution(result) }

  VariableTemplateInstantiation asVariableSubstitution() { this = TVariableSubstitution(result) }

  TypeTemplateParameter getTemplateParameter(int index) {
    result = this.asClassSubstitution().getTemplate().getTemplateArgument(index) or
    result = this.asFunctionSubstitution().getTemplate().getTemplateArgument(index) or
    result = this.asVariableSubstitution().getTemplate().getTemplateArgument(index)
  }

  Type getSubstitutedType(int index) {
    result = this.asClassSubstitution().getTemplateArgument(index) or
    result = this.asFunctionSubstitution().getTemplateArgument(index) or
    result = this.asVariableSubstitution().getTemplateArgument(index)
  }

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
