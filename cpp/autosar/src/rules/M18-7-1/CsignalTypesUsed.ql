/**
 * @id cpp/autosar/csignal-types-used
 * @name M18-7-1: The signal-handling types of <csignal> shall not be used
 * @description Signal handling contains implementation-defined and undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m18-7-1
 *       maintainability
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from TypeMention tm, UserType ut
where
  not isExcluded(tm, BannedLibrariesPackage::csignalTypesUsedQuery()) and
  ut = tm.getMentionedType() and
  ut.hasGlobalOrStdName("sig_atomic_t")
select tm, "Use of <csignal> type '" + ut.getQualifiedName() + "'."
