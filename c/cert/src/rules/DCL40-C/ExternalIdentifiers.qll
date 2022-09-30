import cpp
import codingstandards.cpp.Linkage

class ExternalIdentifiers extends Declaration {
  ExternalIdentifiers() {
    hasExternalLinkage(this) and
    getNamespace() instanceof GlobalNamespace and
    not this.isFromTemplateInstantiation(_) and
    not this.isFromUninstantiatedTemplate(_) and
    not this.hasDeclaringType() and
    not this instanceof UserType and
    not this instanceof Operator and
    not this.hasName("main")
  }
}
