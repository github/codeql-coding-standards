/**
 * @id cpp/autosar/traditional-c-style-casts-used
 * @name A5-2-2: Traditional C-style casts shall not be used
 * @description Traditional C-style casts shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a5-2-2
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from CStyleCast c
where
  not isExcluded(c, BannedSyntaxPackage::traditionalCStyleCastsUsedQuery()) and
  not c.isImplicit() and
  not c.getType() instanceof UnknownType
select c, "Use of explicit C-style Cast"
