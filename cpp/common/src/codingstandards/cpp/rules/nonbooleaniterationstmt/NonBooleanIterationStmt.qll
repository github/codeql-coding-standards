/**
 * Provides a library which includes a `problems` predicate for reporting non-boolean iteration conditions.
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
    // exclude any generated conditions
    not condition.isCompilerGenerated() and
    // exclude any conditions in uninstantiated templates, because their type will be unknown.
    not condition.isFromUninstantiatedTemplate(_) and
    message = "Iteration condition has non boolean type " + explicitConversionType + "."
  )
}
