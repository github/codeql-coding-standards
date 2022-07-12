/**
 * Provides a library which includes a `problems` predicate for reporting the removal of CV qualifications.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class RemoveConstOrVolatileQualificationSharedQuery extends Query { }

Query getQuery() { result instanceof RemoveConstOrVolatileQualificationSharedQuery }

/**
 * `Cast`s that involve a `Pointer` or `Reference` receiver
 * casts with `Variable` receivers are fine
 * because we trust that the developer meant to make a new object
 * with a possibly different qualification
 */
class CastToPointerOrReference extends Cast {
  CastToPointerOrReference() {
    this.getType() instanceof PointerType or this.getType() instanceof ReferenceType
  }

  string fromConst() {
    this.getExpr().getType().(DerivedType).getBaseType*().isConst() and
    result = "const"
  }

  predicate toConst() { this.getActualType().(DerivedType).getBaseType*().isConst() }

  string fromVolatile() {
    this.getExpr().getType().(DerivedType).getBaseType*().isVolatile() and
    result = "volatile"
  }

  predicate toVolatile() { this.getActualType().(DerivedType).getBaseType*().isVolatile() }
}

query predicate problems(CastToPointerOrReference cs, string message) {
  exists(string qualifier |
    not isExcluded(cs, getQuery()) and
    (
      qualifier = cs.fromConst() and // what we have is const
      not cs.toConst() // what we are telling the compiler it is
      or
      qualifier = cs.fromVolatile() and // what we have is volatile
      not cs.toVolatile()
    ) and
    message = "Cast that does not preserve " + qualifier + " qualifier."
  )
}
