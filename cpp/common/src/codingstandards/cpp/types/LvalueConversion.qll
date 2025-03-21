import cpp

/**
 * Get the type of an lvalue after lvalue conversion.
 *
 * This will return the type itself if no conversion is performed.
 */
Type getLvalueConverted(Type t) {
  if exists(performLvalueConversion(t, _))
  then result = performLvalueConversion(t, _)
  else result = t
}

/**
 * Perform lvalue conversion on a type, allowing for a description of why the type was converted
 * if it was.
 *
 * Does not return a value if no lvalue conversion was performed.
 *
 * Warning: This predicate may not return a result if the resulting type is not in the database.
 * For convenience, this is accepted here, otherwise we would have to create a new type to return
 * that wouldn't implement the type APIs and likely wouldn't be very useful.
 */
Type performLvalueConversion(Type t, string reason) {
  result.(PointerType).getBaseType() = t.(ArrayType).getBaseType() and
  reason = "array-to-pointer decay"
  or
  t instanceof RoutineType and
  result.(PointerType).getBaseType() = t and
  reason = "function-to-function-pointer decay"
  or
  isObjectType(t) and
  exists(t.getASpecifier()) and
  result = t.stripTopLevelSpecifiers() and
  reason = "qualifiers removed"
}

private predicate isObjectType(Type t) { not t.stripTopLevelSpecifiers() instanceof PointerType }
