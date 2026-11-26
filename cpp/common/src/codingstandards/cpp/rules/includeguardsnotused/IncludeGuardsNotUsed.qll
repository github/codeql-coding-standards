/**
 * Provides a `problems` predicate for reporting missing or non-unique header include guards.
 */

import cpp
import semmle.code.cpp.headers.MultipleInclusion
import codingstandards.cpp.Customizations
import codingstandards.cpp.Exclusions

abstract class IncludeGuardsNotUsedSharedQuery extends Query { }

Query getQuery() { result instanceof IncludeGuardsNotUsedSharedQuery }

/**
 * A header file whose include guard is blocked by another header file.
 */
class BlockedIncludeGuard extends HeaderFile {
  CorrectIncludeGuard other;

  BlockedIncludeGuard() {
    exists(PreprocessorIfndef ifndef | ifndef.wasNotTaken() and other != this |
      hasIncludeGuard(this, ifndef, _, other.getIncludeGuardName())
    )
  }

  /** Gets the header file whose include guard prevents this header from being included. */
  CorrectIncludeGuard getBlockingIncludeGuard() { result = other }
}

/** A header file that shares its include guard name with another header file. */
class DuplicateIncludeGuard extends CorrectIncludeGuard {
  /** Gets the first other header file, by path, that uses the same include guard name. */
  CorrectIncludeGuard getDuplicate() {
    result =
      min(CorrectIncludeGuard o |
        o != this and o.getIncludeGuardName() = this.getIncludeGuardName()
      |
        o order by o.getAbsolutePath()
      )
  }
}

/**
 * Holds if `file` has a missing or non-unique include guard.
 * `message` is the alert message, and `other` and `name` identify the linked element.
 */
query predicate problems(HeaderFile file, string message, HeaderFile other, string name) {
  not isExcluded(file, getQuery()) and
  other = file.(DuplicateIncludeGuard).getDuplicate() and
  message = "Header file '" + file.getBaseName() + "' uses an include guard also used by $@." and
  name = "header file"
  or
  not isExcluded(file, getQuery()) and
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
