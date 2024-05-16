/**
 * @id cpp/misra/include-directives-preceded-by-preprocessor-directives
 * @name RULE-19-0-3: #include directives should only be preceded by preprocessor directives or comments
 * @description Using anything other than other pre-processor directives or comments before an
 *              '#include' directive makes the code more difficult to read.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-19-0-3
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.preprocessorincludespreceded.PreprocessorIncludesPreceded

class IncludeDirectivesPrecededByPreprocessorDirectivesQuery extends PreprocessorIncludesPrecededSharedQuery {
  IncludeDirectivesPrecededByPreprocessorDirectivesQuery() {
    this = ImportMisra23Package::includeDirectivesPrecededByPreprocessorDirectivesQuery()
  }
}
