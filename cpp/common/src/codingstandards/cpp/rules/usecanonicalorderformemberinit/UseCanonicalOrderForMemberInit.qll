/**
 * Provides a library which includes a `problems` predicate for reporting issues with a syntactic
 * initialization order that does not match up with the semantic initialization order.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Constructor

abstract class UseCanonicalOrderForMemberInitSharedQuery extends Query { }

Query getQuery() { result instanceof UseCanonicalOrderForMemberInitSharedQuery }

/**
 * Gets the target of a `ConstructorInit` and a description of that target.
 */
predicate isConstructorInitTarget(ConstructorInit ci, Element target, string description) {
  target = ci.(ConstructorBaseClassInit).getInitializedClass() and
  description = "class " + target.(Class).getSimpleName()
  or
  target = ci.(ConstructorFieldInit).getTarget() and
  description = "field " + target.(Field).getName()
}

query predicate problems(
  ConstructorInit prevInit, string message, Element prevTarget, string prevTargetDesc,
  Element nextTarget, string nextTargetDesc, ConstructorInit nextInit, string nextDesc
) {
  exists(Constructor c |
    exists(int i, string filepath, int prevLine, int prevCol, int nextLine, int nextCol |
      // Find a pair of initializer which are initialized one after the other
      // Note: getInitializer returns initializers in the sequence they are initialized, not the
      //       order they were written in the Constructor
      prevInit = c.getInitializer(i) and
      nextInit = c.getInitializer(i + 1) and
      not isExcluded(c, getQuery()) and
      not isExcluded(prevInit, getQuery()) and
      not isExcluded(nextInit, getQuery()) and
      // Identify the start line and columns for each initializer
      // Ensuring they occur in the same file (to avoid extractor issues)
      prevInit.getLocation().hasLocationInfo(filepath, prevLine, prevCol, _, _) and
      nextInit.getLocation().hasLocationInfo(filepath, nextLine, nextCol, _, _)
    |
      // Identify if the previous initializer occurs syntactically after the next initializer
      prevLine > nextLine
      or
      prevLine = nextLine and
      prevCol > nextCol
    ) and
    // Identify the targets of the initializer, and provided a description
    // This allows us to report links to the targets for verification
    isConstructorInitTarget(prevInit, prevTarget, prevTargetDesc) and
    isConstructorInitTarget(nextInit, nextTarget, nextTargetDesc) and
    // Ignore compiler generated initializers
    not prevInit.isCompilerGenerated() and
    not nextInit.isCompilerGenerated() and
    message =
      "The initializer " + prevTargetDesc.splitAt(" ", 1) + "(...)" + "  for $@ in the constructor "
        + c.getDeclaringType().getSimpleName() +
        "(...) is initialized before $@, but appears after $@ in the initialization list." and
    nextDesc = nextTargetDesc.splitAt(" ", 1) + "(...)"
  )
}
