import cpp

/*
 * This is a copy of the `arithTypesMatch` predicate from the standard set of
 * queries as of the `codeql-cli/2.9.4` tag in `github/codeql`.
 */

pragma[inline]
predicate arithTypesMatch(Type t1, Type t2) {
  t1 = t2
  or
  t1.getSize() = t2.getSize() and
  (
    t1 instanceof IntegralOrEnumType and
    t2 instanceof IntegralOrEnumType
    or
    t1 instanceof FloatingPointType and
    t2 instanceof FloatingPointType
  )
}

predicate typesCompatible(Type t1, Type t2) {
  if t1 instanceof BuiltInType and t2 instanceof BuiltInType
  then
    //for simple types consider compatible
    arithTypesMatch(t1, t2)
  else
    //otherwise include type qualifiers and typedef names
    t1 = t2
}
