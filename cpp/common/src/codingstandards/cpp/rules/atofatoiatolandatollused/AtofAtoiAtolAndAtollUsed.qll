/**
 * Provides a library with a `problems` predicate for the following issue:
 * The library functions atof, atoi, atol and atoll from <cstdlib> shall not be used.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

private string atoi() { result = ["atof", "atoi", "atol", "atoll"] }

abstract class AtofAtoiAtolAndAtollUsedSharedQuery extends Query { }

Query getQuery() { result instanceof AtofAtoiAtolAndAtollUsedSharedQuery }

query predicate problems(FunctionCall fc, string message) {
  exists(Function f |
    not isExcluded(fc, getQuery()) and
    f = fc.getTarget() and
    f.getName() = atoi() and
    f.getFile().getBaseName() = "stdlib.h" and
    message = "Call to banned function " + f.getName() + "."
  )
}
