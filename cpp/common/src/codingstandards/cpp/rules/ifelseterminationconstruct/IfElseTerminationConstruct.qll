/**
 * Provides a library with a `problems` predicate for the following issue:
 * The final else statement is a defensive programming technique.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class IfElseTerminationConstructSharedQuery extends Query { }

Query getQuery() { result instanceof IfElseTerminationConstructSharedQuery }

query predicate problems(IfStmt ifStmt, string message, IfStmt ifLocation, string ifElseString) {
  not isExcluded(ifStmt, getQuery()) and
  exists(IfStmt ifElse |
    ifStmt.getElse() = ifElse and
    not ifElse.hasElse()
  ) and
  ifLocation = ifStmt and
  message = "The $@ construct does not terminate with else statement." and
  ifElseString = "`if...else`"
}
