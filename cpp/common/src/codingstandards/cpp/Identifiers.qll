import cpp
import codingstandards.cpp.Linkage

class ExternalIdentifiers extends InterestingIdentifiers {
  ExternalIdentifiers() {
    hasExternalLinkage(this) and
    getNamespace() instanceof GlobalNamespace
  }

  string getSignificantName() {
    //C99 states the first 31 characters of external identifiers are significant
    //C90 states the first 6 characters of external identifiers are significant and case is not required to be significant
    //C90 is not currently considered by this rule
    result = this.getName().prefix(31)
  }
}

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

//Declarations that omit type - C90 compiler assumes int
predicate isDeclaredImplicit(Declaration d) {
  d.hasSpecifier("implicit_int") and
  exists(Type t |
    (d.(Variable).getType() = t or d.(Function).getType() = t) and
    // Exclude "short" or "long", as opposed to "short int" or "long int".
    t instanceof IntType and
    // Exclude "signed" or "unsigned", as opposed to "signed int" or "unsigned int".
    not exists(IntegralType it | it = t | it.isExplicitlySigned() or it.isExplicitlyUnsigned())
  )
}
