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
    castFrom = cast.getExpr().getType().(PointerType).getBaseType() and
    cast.getType().(PointerType).getBaseType() = castTo and
    castTo = castFrom.getADerivedClass+() and
    message =
      "A pointer to virtual base class " + castFrom.getName() +
        " is not cast to a pointer of derived class " + castTo.getName() + " using a dynamic_cast."
  )
}
