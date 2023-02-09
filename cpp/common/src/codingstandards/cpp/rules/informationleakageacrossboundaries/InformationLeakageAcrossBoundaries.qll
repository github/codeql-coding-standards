/**
 * Provides a library which includes a `problems` predicate for reporting potential information leakage across trust boundaries, relating to uninitialized memory in structs.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions
import codingstandards.cpp.trustboundary.UninitializedField

abstract class InformationLeakageAcrossBoundariesSharedQuery extends Query { }

Query getQuery() { result instanceof InformationLeakageAcrossBoundariesSharedQuery }

query predicate problems(Element e, string message) {
  uninitializedFieldQuery(e, message) and
  not isExcluded(e, getQuery())
}
