/**
 * @id cpp/autosar/register-keyword-used
 * @name A7-1-4: The register keyword shall not be used
 * @description The register keyword shall not be used.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a7-1-4
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from Variable v
where
  not isExcluded(v, BannedSyntaxPackage::registerKeywordUsedQuery()) and v.hasSpecifier("register")
select v, "Use of register specifier on variable " + v.getName() + "."
