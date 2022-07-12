/**
 * Provides a library which includes a `problems` predicate for reporting the use of destroyed values in constructor/destructor function-try-catch blocks.
 */

import cpp
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class DestroyedValueReferencedInDestructorCatchBlockSharedQuery extends Query { }

Query getQuery() { result instanceof DestroyedValueReferencedInDestructorCatchBlockSharedQuery }

query predicate problems(
  ThisExpr te, string message, MemberFunction constructorOrDestructor,
  string constructorOrDestructorName
) {
  exists(FunctionTryStmt tryStmt, CatchBlock catchBlock |
    not isExcluded(te, getQuery()) and
    (
      constructorOrDestructor instanceof Constructor or
      constructorOrDestructor instanceof Destructor
    ) and
    constructorOrDestructor.getBlock() = tryStmt.getStmt() and
    catchBlock = tryStmt.getACatchClause() and
    te.getEnclosingElement*() = catchBlock and
    message = "Reference to member or base class of an object in catch handler for $@." and
    constructorOrDestructorName = constructorOrDestructor.getName()
  )
}
