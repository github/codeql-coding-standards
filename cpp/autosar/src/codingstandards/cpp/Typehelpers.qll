import cpp

pragma[inline]
predicate areCompatible(Type t1, Type t2) {
  // TODO - Enhance this to with a performant predicate for testing
  // compatability.
  t1.getUnspecifiedType() = t2.getUnspecifiedType()
}
