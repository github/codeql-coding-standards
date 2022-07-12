/**
 * @id cpp/autosar/pragma-directive-used
 * @name A16-7-1: The #pragma directive shall not be used
 * @description The '#pragma' directive is implementation defined and therefore can be inconsistent
 *              or hard to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a16-7-1
 *       readability
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from PreprocessorPragma p
where not isExcluded(p, MacrosPackage::pragmaDirectiveUsedQuery())
select p, "Use of '" + p.toString() + "' directive."
