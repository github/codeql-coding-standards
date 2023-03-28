/**
 * Provides a library which includes a `problems` predicate for reporting
 * instances of memcmp being used to access bits of an object representation
 * that are not part of the object's value representation.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import semmle.code.cpp.padding.Padding
import semmle.code.cpp.security.BufferAccess

abstract class MemcmpUsedToComparePaddingDataSharedQuery extends Query { }

Query getQuery() { result instanceof MemcmpUsedToComparePaddingDataSharedQuery }

query predicate problems(MemcmpBA cmp, string message) {
  not isExcluded(cmp, getQuery()) and
  cmp.getBuffer(_, _)
      .getUnconverted()
      .getUnspecifiedType()
      .(PointerType)
      .getBaseType()
      .getUnspecifiedType() instanceof PaddedType and
  message =
    cmp.getName() + " accesses bits which are not part of the object's value representation."
}
