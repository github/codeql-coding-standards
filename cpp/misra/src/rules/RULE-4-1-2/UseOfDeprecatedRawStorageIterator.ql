/**
 * @id cpp/misra/use-of-deprecated-raw-storage-iterator
 * @name RULE-4-1-2: Class raw_storage_iterator is a deprecated language feature and should not be used
 * @description Deprecated language features such as raw_storage_iterator are only supported for
 *              backwards compatibility; these are considered bad practice, or have been superceded
 *              by better alternatives.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/misra/id/rule-4-1-2
 *       scope/single-translation-unit
 *       maintainability
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra

from
where
  not isExcluded(x, Toolchain3Package::useOfDeprecatedRawStorageIteratorQuery()) and
select
