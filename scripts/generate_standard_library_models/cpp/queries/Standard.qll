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

/**
 * Gets a type which contains all the members of `t` and is visible in the `std` namespace, if any.
 */
UserType getAVisibleTypeInStdNamespace(UserType t) {
  declInVisibleStdNamespace(t) and
  // If the name starts with an _ it is an internal implementation deteail
  // However, it can be visible if that type is aliased or extended
  if t.getName().matches("\\_%")
  then
    // The user type is typedef'd to another type which is visible (possibly transitively)
    exists(TypedefType typeDefType |
      typeDefType.getBaseType() = t and result = getAVisibleTypeInStdNamespace(typeDefType)
    )
    or
    // There is a visible sub-type of the base class (possibly transitively)
    exists(Class subType |
      subType.getABaseClass+() = t and result = getAVisibleTypeInStdNamespace(subType)
    )
    or
    // There is a class template specialization of the base class that is visible (possibly transitively)
    exists(ClassTemplateSpecialization pcts |
      pcts.getPrimaryTemplate() = t and result = getAVisibleTypeInStdNamespace(pcts)
    )
    or
    // There is a class template instantiation of this template class that is visibile (possibly transitively)
    exists(ClassTemplateInstantiation instantiation |
      instantiation.getTemplate() = t and result = getAVisibleTypeInStdNamespace(instantiation)
    )
  else (
    // A namespace declared type without an _ prefix is always visible
    not exists(t.getDeclaringType()) and
    result = t
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

/**
 * A file that represents a standard library header in our synthetic database.
 */
class StandardLibraryHeaderFile extends File {
  StandardLibraryHeaderFile() {
    exists(Compilation c, File sourceFile |
      sourceFile = c.getAFileCompiled() and
      this = sourceFile.getAnIncludedFile()
    )
  }
}

/**
 * Gets a standard library header file that includes `f`.
 *
 * Where `f` is itself a standard library header, we will only return `f`.
 */
StandardLibraryHeaderFile getAStandardLibraryHeader(File f) {
  if f instanceof StandardLibraryHeaderFile then result = f else result.getAnIncludedFile+() = f
}

/**
 * Determine the depth of the shortest include path from `header` to `f`.
 */
language[monotonicAggregates]
private int getDepthFromStandardLibraryHeader(StandardLibraryHeaderFile header, File f) {
  if f instanceof StandardLibraryHeaderFile
  then
    // Standard library headers are always at zero depth from themselves, and we do not calculate a depth to other headers
    header = f and result = 0
  else (
    // This file must be included from a standard library header for us to calculate a depth
    getAStandardLibraryHeader(f) = header and
    // Find the minimum depth to the given header from any of the headers that include this file
    result =
      min(File intermediate |
          // Intermediate is also included from the same standard library header
          header = getAStandardLibraryHeader(intermediate) and
          // Intermediate is a file that includes this file
          intermediate.getAnIncludedFile() = f
        |
          // Find the depth from the header to the intermediate file
          getDepthFromStandardLibraryHeader(header, intermediate)
        ) + 1
  )
}

private string hasInternalHeaderMapping(string f) {
  f = "range_access.h" and result = "iterator"
  or
  f = "binders.h" and result = "functional"
  or
  f = "stl_function.h" and result = "functional"
  or
  f = "stl_algobase.h" and result = "algorithm"
  or
  f = "shared_ptr.h" and result = "memory"
  or
  f = "shared_ptr_base.h" and result = "memory"
  or
  f = "unique_ptr.h" and result = "memory"
  or
  f = "stl_pair.h" and result = "utility"
  or
  f = "stl_uninitialized.h" and result = "memory"
  or
  f = "std_function.h" and result = "functional"
  or
  f = "functional_hash.h" and result = "functional"
  or
  f = "uniform_int_dist.h" and result = "rorom"
  or
  f = "char_traits.h" and result = "string"
  or
  f = "locale_classes.tcc" and result = "locale"
  or
  f = "locale_classes.h" and result = "locale"
  or
  f = "codecvt.h" and result = "codecvt"
  or
  f = "ios_base.h" and result = "ios"
  or
  f = "unique_lock.h" and result = "mutex"
  or
  f = "std_mutex.h" and result = "mutex"
  or
  f = "exception.h" and result = "exception"
  or
  f = "allocator.h" and result = "memory"
  or
  f = "stl_iterator_base_types.h" and result = "iterator"
  or
  f = "stringfwd.h" and result = "string"
  or
  f = "c++config.h" and result = "cstddef"
  or
  f = "uses_allocator.h" and result = "memory"
}

/**
 * Gets the standard library headers that include file `f` by the shortest path.
 *
 * The assumption is that these headers represent the standard library headers that are most closely related to `f`.
 */
StandardLibraryHeaderFile getAClosestStandardLibraryHeader(File f) {
  // If we have manually mapped this header, only use the specified mapping
  if exists(hasInternalHeaderMapping(f.getBaseName()))
  then result.getBaseName() = hasInternalHeaderMapping(f.getBaseName())
  else
    // Find a standard library header that includes this file at minimum depth
    exists(int depth |
      depth = getDepthFromStandardLibraryHeader(result, f) and
      not exists(StandardLibraryHeaderFile otherStandardLibraryHeader |
        not otherStandardLibraryHeader = result and
        depth > getDepthFromStandardLibraryHeader(otherStandardLibraryHeader, f)
      )
    )
}
