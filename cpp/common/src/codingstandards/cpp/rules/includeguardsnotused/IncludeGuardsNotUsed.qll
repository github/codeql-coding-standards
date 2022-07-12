/**
 * Provides a library which includes a `problems` predicate for reporting header files without an include guard.
 */

import cpp
import semmle.code.cpp.headers.MultipleInclusion
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class IncludeGuardsNotUsedSharedQuery extends Query { }

Query getQuery() { result instanceof IncludeGuardsNotUsedSharedQuery }

class BlockedIncludeGuard extends HeaderFile {
  CorrectIncludeGuard other;

  BlockedIncludeGuard() {
    exists(PreprocessorIfndef ifndef | ifndef.wasNotTaken() and other != this |
      hasIncludeGuard(this, ifndef, _, other.getIncludeGuardName())
    )
  }

  CorrectIncludeGuard getBlockingIncludeGuard() { result = other }
}

query predicate problems(HeaderFile file, string message, HeaderFile other, string name) {
  not file instanceof CorrectIncludeGuard and
  if file instanceof BlockedIncludeGuard
  then
    message =
      "Header file " + file.getBaseName() +
        " is never included by reusing the include guard used by $@." and
    other = file.(BlockedIncludeGuard).getBlockingIncludeGuard() and
    name = "include guard"
  else (
    message = "Header file " + file.getBaseName() + " is missing expected include guard." and
    other = file and
    name = ""
  )
}
