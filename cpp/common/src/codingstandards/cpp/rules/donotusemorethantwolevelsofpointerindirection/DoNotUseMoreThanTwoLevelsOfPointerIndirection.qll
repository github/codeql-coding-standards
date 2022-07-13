/**
 * Provides a library which includes a `problems` predicate for reporting
 * variables declared with more than two levels of pointer indirection.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class DoNotUseMoreThanTwoLevelsOfPointerIndirectionSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotUseMoreThanTwoLevelsOfPointerIndirectionSharedQuery }

Type getBaseType(DerivedType t) { result = t.getBaseType() }

int levelsOfIndirection(Type t) {
  if t instanceof FunctionPointerType
  then result = t.(FunctionPointerType).getReturnType().getPointerIndirectionLevel()
  else result = t.getPointerIndirectionLevel()
}

int paramLevelsOfIndirection(Type t) {
  if t instanceof ArrayType
  then result = 1 + levelsOfIndirection(t.(ArrayType).getBaseType())
  else result = levelsOfIndirection(t)
}

query predicate problems(Variable v, string message) {
  not isExcluded(v, getQuery()) and
  exists(Type type |
    type = getBaseType*(v.getType()) and
    (
      if v instanceof Parameter
      then paramLevelsOfIndirection(type) > 2
      else levelsOfIndirection(type) > 2
    )
  ) and
  message =
    "The declaration of " + v.getName() + " contain more than two levels of pointer indirection."
}
