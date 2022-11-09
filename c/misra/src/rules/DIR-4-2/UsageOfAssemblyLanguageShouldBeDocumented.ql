/**
 * @id c/misra/usage-of-assembly-language-should-be-documented
 * @name DIR-4-2: All usage of assembly language should be documented
 * @description 
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/dir-4-2
 *       maintainability
 *       readability
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.usageofassemblernotdocumented.UsageOfAssemblerNotDocumented

class UsageOfAssemblyLanguageShouldBeDocumentedQuery extends UsageOfAssemblerNotDocumentedSharedQuery {
  UsageOfAssemblyLanguageShouldBeDocumentedQuery() {
    this = Language2Package::usageOfAssemblyLanguageShouldBeDocumentedQuery()
  }
}
