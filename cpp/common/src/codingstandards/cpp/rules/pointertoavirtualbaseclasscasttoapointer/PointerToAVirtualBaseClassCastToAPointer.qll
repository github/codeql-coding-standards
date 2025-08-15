/**
 * Provides a library with a `problems` predicate for the following issue:
 * A pointer to a virtual base class shall only be cast to a pointer to a derived class
 * by means of dynamic_cast, otherwise the cast has undefined behavior.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class PointerToAVirtualBaseClassCastToAPointerSharedQuery extends Query { }

Query getQuery() { result instanceof PointerToAVirtualBaseClassCastToAPointerSharedQuery }

query predicate problems(Cast cast, string message) {
  exists(VirtualBaseClass castFrom, Class castTo |
    not isExcluded(cast, getQuery()) and
    not cast instanceof DynamicCast and
    castTo = castFrom.getADerivedClass+() and
    message =
      "A pointer to virtual base class " + castFrom.getName() +
        " is not cast to a pointer of derived class " + castTo.getName() + " using a dynamic_cast."
  |
    // Pointer cast
    castFrom = cast.getExpr().getType().stripTopLevelSpecifiers().(PointerType).getBaseType() and
    cast.getType().stripTopLevelSpecifiers().(PointerType).getBaseType() = castTo
    or
    // Reference type cast
    castFrom = cast.getExpr().getType().stripTopLevelSpecifiers() and
    // Not actually represented as a reference type in our model - instead as the
    // type itself
    cast.getType().stripTopLevelSpecifiers() = castTo
  )
}
