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

query predicate problems(
  Cast cast, string message, VirtualClassDerivation derivation, string derivationDescription
) {
  exists(Class castFrom, VirtualBaseClass virtualBaseClass, Class castTo, string type |
    not isExcluded(cast, getQuery()) and
    not cast instanceof DynamicCast and
    castTo = virtualBaseClass.getADerivedClass+() and
    virtualBaseClass = castFrom.getADerivedClass*() and
    derivation = virtualBaseClass.getAVirtualDerivation() and
    derivation.getDerivedClass().getADerivedClass*() = castTo and
    derivationDescription = "derived through virtual base class " + virtualBaseClass.getName() and
    message =
      "dynamic_cast not used for cast from " + type + " to base class " + castFrom.getName() +
        " to derived class " + castTo.getName() + " which is  $@."
  |
    // Pointer cast
    castFrom = cast.getExpr().getType().stripTopLevelSpecifiers().(PointerType).getBaseType() and
    cast.getType().stripTopLevelSpecifiers().(PointerType).getBaseType() = castTo and
    type = "pointer"
    or
    // Reference type cast
    castFrom = cast.getExpr().getType().stripTopLevelSpecifiers() and
    // Not actually represented as a reference type in our model - instead as the
    // type itself
    cast.getType().stripTopLevelSpecifiers() = castTo and
    type = "reference"
  )
}
