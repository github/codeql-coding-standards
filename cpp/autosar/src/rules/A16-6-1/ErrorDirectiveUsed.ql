/**
 * @id cpp/autosar/error-directive-used
 * @name A16-6-1: #error directive shall not be used
 * @description The '#error' directive makes code harder to read.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a16-6-1
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from PreprocessorError e
where not isExcluded(e, MacrosPackage::errorDirectiveUsedQuery())
select e, "Use of #error directive."
