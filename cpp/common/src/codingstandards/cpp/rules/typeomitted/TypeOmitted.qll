/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class TypeOmittedSharedQuery extends Query { }

Query getQuery() { result instanceof TypeOmittedSharedQuery }

query predicate problems(Declaration d, string message) {
  not isExcluded(d, getQuery()) and
  d.hasSpecifier("implicit_int") and
  exists(Type t |
    (d.(Variable).getType() = t or d.(Function).getType() = t) and
    // Exclude "short" or "long", as opposed to "short int" or "long int".
    t instanceof IntType and
    // Exclude "signed" or "unsigned", as opposed to "signed int" or "unsigned int".
    not exists(IntegralType it | it = t | it.isExplicitlySigned() or it.isExplicitlyUnsigned())
  ) and
  message = "Declaration " + d.getName() + " is missing a type specifier."
}
