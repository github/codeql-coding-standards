/**
 * Provides a library which includes a `problems` predicate for uses of rand()
 * for generating random numbers.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class DoNotUseRandForGeneratingPseudorandomNumbersSharedQuery extends Query { }

Query getQuery() { result instanceof DoNotUseRandForGeneratingPseudorandomNumbersSharedQuery }

query predicate problems(FunctionCall fc, string message) {
  not isExcluded(fc, getQuery()) and
  fc.getTarget().hasGlobalOrStdName("rand") and
  message = "Use of banned function " + fc.getTarget().getQualifiedName() + "."
}
