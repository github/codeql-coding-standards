/**
 * @id cpp/misra/include-outside-guard
 * @name RULE-19-2-1: Comments are the only content permitted outside of the scope of an include guard in a header file
 * @description Include directives shall be within the scope of an include guard.
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

from Include include, CorrectIncludeGuard includeGuard, HeaderFile header
where
  not isExcluded(include, PreprocessorPackage::includeOutsideGuardQuery()) and
  includeGuard.getFile() = header and
  header = include.getFile() and
  isOutside(includeGuard, include.getLocation())
select include, "Include is outside of its header file's $@.", includeGuard.getIfndef(),
  "include guard"
