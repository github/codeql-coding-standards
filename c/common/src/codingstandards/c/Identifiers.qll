import cpp

//Identifiers that are candidates for checking uniqueness
class InterestingIdentifiers extends Declaration {
  InterestingIdentifiers() {
    not this.isFromTemplateInstantiation(_) and
    not this.isFromUninstantiatedTemplate(_) and
    not this instanceof TemplateParameter and
    not this.hasDeclaringType() and
    not this instanceof Operator and
    not this.hasName("main") and
    exists(this.getADeclarationLocation())
  }

  //this definition of significant relies on the number of significant characters for a macro name (C99)
  //this is used on macro name comparisons only
  //not necessarily against other types of identifiers
  string getSignificantNameComparedToMacro() { result = this.getName().prefix(63) }
}
