/**
 * Provides a library with a `problems` predicate for the following issue:
 * An array passed as a function argument shall not decay to a pointer.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class ArrayPassedAsFunctionArgumentDecayToAPointerSharedQuery extends Query { }

Query getQuery() { result instanceof ArrayPassedAsFunctionArgumentDecayToAPointerSharedQuery }

predicate arrayToPointerDecay(Access ae, Parameter p) {
  (
    p.getType() instanceof PointerType and
    // exclude parameters of void* because then it assumed the caller can pass in dimensions through other means.
    // examples are uses in `memset` or `memcpy`
    not p.getType() instanceof VoidPointerType
    or
    p.getType() instanceof ArrayType
  ) and
  ae.getType() instanceof ArrayType and
  // exclude char[] arrays because we assume that we can determine its dimension by looking for a NULL byte.
  not ae.getType().(ArrayType).getBaseType() instanceof CharType
}

query predicate problems(
  Element e, string message, Variable array, string array_string, Parameter decayedArray,
  string decayedArray_string, Function f, string f_string
) {
  exists(FunctionCall fc, VariableAccess arrayAccess, int i |
    not isExcluded(e, getQuery()) and
    arrayAccess = array.getAnAccess() and
    f = fc.getTarget() and
    arrayAccess = fc.getArgument(i) and
    decayedArray = f.getParameter(i) and
    arrayToPointerDecay(arrayAccess, decayedArray) and
    not arrayAccess.isAffectedByMacro() and
    e = fc.getArgument(i) and
    array_string = array.getName() and
    decayedArray_string = decayedArray.getName() and
    f_string = f.getName() and
    message = "The array $@ decays to the pointer $@ when passed as an argument to the function $@."
  )
}
