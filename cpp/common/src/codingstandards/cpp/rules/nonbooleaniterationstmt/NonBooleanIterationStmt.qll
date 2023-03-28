/**
 * Provides a library which includes a `problems` predicate for reporting....
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NonBooleanIterationStmtSharedQuery extends Query { }

Query getQuery() { result instanceof NonBooleanIterationStmtSharedQuery }

query predicate problems(Loop loopStmt, string message) {
  not isExcluded(loopStmt, getQuery()) and
  exists(Expr condition, Type explicitConversionType |
    condition = loopStmt.getCondition() and
    explicitConversionType = condition.getExplicitlyConverted().getType().getUnspecifiedType() and
    not explicitConversionType instanceof BoolType and
    message = "Iteration condition has non boolean type " + explicitConversionType + "."
  )
}
