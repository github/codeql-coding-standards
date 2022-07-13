import cpp

class GlobalOrStdVariable extends GlobalOrNamespaceVariable {
  GlobalOrStdVariable() {
    this.getNamespace() instanceof GlobalNamespace
    or
    this.getNamespace() instanceof StdNamespace
  }
}

from GlobalOrStdVariable v
where not v.getName().matches("\\_%") // exclude internal objects that start with a '_' or a '__'
select v.getName(), v.getQualifiedName()
