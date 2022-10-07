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

  string getSignificantName() { result = this.getName().prefix(31) }
}
