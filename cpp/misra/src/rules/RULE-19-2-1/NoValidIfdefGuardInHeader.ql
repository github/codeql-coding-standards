/**
 * @id cpp/misra/no-valid-ifdef-guard-in-header
 * @name RULE-19-2-1: Precautions shall be taken in order to prevent the contents of a header file being included more
 * @description Precautions shall be taken in order to prevent the contents of a header file being
 *              included more than once.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-2-1
 *       scope/single-translation-unit
 *       maintainability
 *       correctness
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.cpp.misra
import semmle.code.cpp.headers.MultipleInclusion

predicate isOutside(CorrectIncludeGuard includeGuard, Location location) {
  location.getFile() = includeGuard.getFile() and
  (
    location.isBefore(includeGuard.getIfndef().getLocation())
    or
    includeGuard.getEndif().getLocation().isBefore(location)
  )
}

from HeaderFile included
where
  not isExcluded(included, PreprocessorPackage::noValidIfdefGuardInHeaderQuery()) and
  not exists(CorrectIncludeGuard includeGuard |
    includeGuard.getFile() = included and
    // Stricter: define is before all other contents
    //not included
    //    .getATopLevelDeclaration()
    //    .getLocation()
    //    .isBefore(includeGuard.getDefine().getLocation()) and
    // Stricter: do not allow includes outside of the inclusion guard
    not exists(Include include | isOutside(includeGuard, include.getLocation()))
  )
select included, "File does not have a well formatted include guard."
