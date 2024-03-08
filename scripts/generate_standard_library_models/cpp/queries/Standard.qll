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

predicate declInVisibleStdNamespace(Declaration d) { inVisibleStdNamespace(d.getNamespace()) }

/**
 * Holds if the given namespace is inside a `std` namespace, and not in a `__detail` namespace.
 */
predicate inVisibleStdNamespace(Namespace namespace) {
  not namespace.getName() = "__detail" and
  (
    namespace instanceof StdNS
    or
    inVisibleStdNamespace(namespace.getParentNamespace())
  )
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
