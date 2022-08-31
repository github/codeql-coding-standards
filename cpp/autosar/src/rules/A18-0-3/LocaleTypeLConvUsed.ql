/**
 * @id cpp/autosar/locale-type-l-conv-used
 * @name A18-0-3: The library <clocale> (locale.h) type lconv shall not be used
 * @description The locale library, which defines the type lconv, shall not be used as it may
 *              introduce data races.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a18-0-3
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
  not isExcluded(tm, BannedLibrariesPackage::localeTypeLConvUsedQuery()) and
  tm.getMentionedType() = ut and
  ut.hasGlobalOrStdName("lconv")
select tm, "Use of <clocale> type '" + ut.getQualifiedName() + "'."
