import cpp
import codingstandards.cpp.StdNamespace

string getStandard() {
  exists(Compilation c, string flag |
    flag =
      max(string std, int index |
        c.getArgument(index) = std and std.matches("-std=%")
      |
        std order by index
      ) and
    result = flag.replaceAll("-std=", "").toUpperCase()
  )
}

predicate declInStdNamespace(Declaration d) { inStdNamespace(d.getNamespace()) }

/**
 * Holds if the given namespace is inside a `std` namespace.
 */
predicate inStdNamespace(Namespace namespace) {
  namespace instanceof StdNS
  or
  inStdNamespace(namespace.getParentNamespace())
}

private string getParentName(Namespace namespace) {
  result = namespace.getParentNamespace().getName() and
  result != ""
}

/**
 * Gets a string representing the visible namespace of this namespace, taking into account inline namespaces.
 */
string getVisibleNamespaceString(Namespace namespace) {
  if exists(getParentName(namespace))
  then
    exists(string parentNamespace |
      parentNamespace = getVisibleNamespaceString(namespace.getParentNamespace())
    |
      if namespace.isInline()
      then result = parentNamespace
      else result = parentNamespace + "::" + namespace.getName()
    )
  else result = namespace.getName()
}
