/**
 * @id c/misra/forbidden-characters-in-header-file-name
 * @name RULE-20-2: The ', " or \ characters and the /* or // character sequences shall not occur in a header file name
 * @description Using any of the following characters in an '#include' directive as a part of the
 *              header file name is undefined behaviour: ', ", /*, //, \.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-20-2
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 *       coding-standards/baseline/style
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.preprocessorincludesforbiddenheadernames.PreprocessorIncludesForbiddenHeaderNames

class PreprocessorIncludesForbiddenHeaderNames extends PreprocessorIncludesForbiddenHeaderNamesSharedQuery
{
  PreprocessorIncludesForbiddenHeaderNames() {
    this = Preprocessor1Package::forbiddenCharactersInHeaderFileNameQuery()
  }
}
