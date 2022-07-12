/**
 * @id c/misra/include-directives-preceded-by-directives-or-comments
 * @name RULE-20-1: #include directives should only be preceded by preprocessor directives or comments
 * @description Using anything other than other pre-processor directives or comments before an
 *              '#include' directive makes the code more difficult to read.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-20-1
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.preprocessorincludespreceded.PreprocessorIncludesPreceded

class PreprocessorIncludesPrecededQuery extends PreprocessorIncludesPrecededSharedQuery {
  PreprocessorIncludesPrecededQuery() {
    this = Preprocessor1Package::includeDirectivesPrecededByDirectivesOrCommentsQuery()
  }
}
