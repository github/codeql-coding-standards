/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

private string atoi() { result = ["atof", "atoi", "atol", "atoll"] }

abstract class AtofAtoiAtolAndAtollUsed_sharedSharedQuery extends Query { }

Query getQuery() { result instanceof AtofAtoiAtolAndAtollUsed_sharedSharedQuery }

query predicate problems(FunctionCall fc, string message) {
  exists(Function f |
    not isExcluded(fc, getQuery()) and
    f = fc.getTarget() and
    f.getName() = atoi() and
    f.getFile().getBaseName() = "stdlib.h" and
    message = "Call to banned function " + f.getName() + "."
  )
}
