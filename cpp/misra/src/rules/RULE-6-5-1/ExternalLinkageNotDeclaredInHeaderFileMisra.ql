/**
 * @id cpp/misra/external-linkage-not-declared-in-header-file-misra
 * @name RULE-6-5-1: Objects or functions with external linkage shall be declared in a header file
 * @description Using objects or functions with external linkage in implementation files makes code
 *              harder to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/misra/id/rule-6-5-1
 *       correctness
 *       maintainability
 *       readability
 *       scope/single-translation-unit
 *       external/misra/enforcement/decidable
 *       external/misra/obligation/advisory
 */

import cpp
import codingstandards.cpp.misra
import codingstandards.cpp.rules.externallinkagenotdeclaredinheaderfile.ExternalLinkageNotDeclaredInHeaderFile

class ExternalLinkageNotDeclaredInHeaderFileMisraQuery extends ExternalLinkageNotDeclaredInHeaderFileSharedQuery
{
  ExternalLinkageNotDeclaredInHeaderFileMisraQuery() {
    this = Linkage1Package::externalLinkageNotDeclaredInHeaderFileMisraQuery()
  }
}
