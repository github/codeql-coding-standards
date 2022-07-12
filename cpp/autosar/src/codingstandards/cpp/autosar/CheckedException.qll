/**
 * Provides a library modeling checked and unchecked exceptions as defined by the AUTOSAR C++ standard.
 */

import cpp
import codingstandards.cpp.standardlibrary.Exceptions

/** A checked exception according to AUTOSAR C++, denoted by a `@checkedException` marker. */
class CheckedException extends Class {
  CheckedException() {
    exists(Comment c, string contents |
      c.getCommentedElement() = this.getADeclarationEntry() and
      contents =
        c.getContents().splitAt("\n").regexpFind("^\\s*(//|\\*)\\s*@checkedException\\s*$", _, _)
    )
  }
}

/**
 * An unchecked exception according to AUTOSAR C++, identified by extending std::exception and not
 * being a checked exception.
 */
class UncheckedException extends Class {
  UncheckedException() {
    getABaseClass*() instanceof StdException and
    not this instanceof CheckedException
  }
}

/** Gets a `CheckedException` declared to be thrown by this function declaration entry. */
CheckedException getADeclaredThrowsCheckedException(FunctionDeclarationEntry fde) {
  exists(Comment c |
    c.getCommentedElement() = fde and
    result.getName() =
      c.getContents()
          .splitAt("\n")
          .regexpCapture("^\\s*(\\/\\/|\\*)\\s*@throw ([a-zA-Z_0-9]+)\\s*.*$", 2)
  )
}
