/**
 * Provides a library with a `problems` predicate for the following issue:
 * All constructors of a class should explicitly initialize all of its virtual base
 * classes and immediate base classes.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.Constructor

abstract class InitializeAllVirtualBaseClassesSharedQuery extends Query { }

Query getQuery() { result instanceof InitializeAllVirtualBaseClassesSharedQuery }

query predicate problems(
  Constructor c, string message, Class declaringType, string declaringType_string, Class baseClass,
  string baseClass_string
) {
  exists(string type |
    not isExcluded(c, getQuery()) and
    declaringType = c.getDeclaringType() and
    (
      declaringType.getABaseClass() = baseClass and type = ""
      or
      baseClass.(VirtualBaseClass).getAVirtuallyDerivedClass().getADerivedClass+() = declaringType and
      type = " virtual"
    ) and
    // There is not an initializer on the constructor for this particular base class
    not exists(ConstructorBaseClassInit init |
      c.getAnInitializer() = init and
      init.getInitializedClass() = baseClass and
      not init.isCompilerGenerated()
    ) and
    // Must be a defined constructor
    c.hasDefinition() and
    // Not a compiler-generated constructor
    not c.isCompilerGenerated() and
    // Not a defaulted constructor
    not c.isDefaulted() and
    // Not a deleted constructor
    not c.isDeleted() and
    declaringType_string = declaringType.getSimpleName() and
    baseClass_string = baseClass.getSimpleName() and
    message =
      "Constructor for $@ does not explicitly call constructor for" + type + " base class $@."
  )
}
