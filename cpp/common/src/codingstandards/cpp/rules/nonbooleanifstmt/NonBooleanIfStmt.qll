/**
 * Provides a library which includes a `problems` predicate for reporting if statements which have non boolean conditions.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class NonBooleanIfStmtSharedQuery extends Query { }

Query getQuery() { result instanceof NonBooleanIfStmtSharedQuery }

query predicate problems(Expr condition, string message) {
  not isExcluded(condition, getQuery()) and
  exists(IfStmt ifStmt, Type explicitConversionType |
    condition = ifStmt.getCondition() and
    //exclude any generated conditions
    not condition.isCompilerGenerated() and
    not ifStmt.isFromUninstantiatedTemplate(_) and
    explicitConversionType = condition.getExplicitlyConverted().getUnderlyingType() and
    not explicitConversionType instanceof BoolType and
    message = "If condition has non boolean type " + explicitConversionType + "."
  )
}
