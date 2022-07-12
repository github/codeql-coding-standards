/**
 * @id cpp/autosar/include-directives-not-preceded-by-directives-or-comments
 * @name M16-0-1: #include directives in a file shall only be preceded by other pre-processor directives or comments
 * @description Using anything other than other pre-processor directives or comments before an
 *              '#include' directive makes the code more difficult to read.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/m16-0-1
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.preprocessorincludespreceded.PreprocessorIncludesPreceded

class PreprocessorIncludesPrecededQuery extends PreprocessorIncludesPrecededSharedQuery {
  PreprocessorIncludesPrecededQuery() {
    this = MacrosPackage::includeDirectivesNotPrecededByDirectivesOrCommentsQuery()
  }
}
