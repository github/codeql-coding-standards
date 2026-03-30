/**
 * @id cpp/autosar/external-linkage-not-declared-in-header-file
 * @name A3-3-1: Objects or functions with external linkage (including members of named namespaces) shall be declared in a header file
 * @description Using objects or functions with external linkage in implementation files makes code
 *              harder to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-3-1
 *       correctness
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.externallinkagenotdeclaredinheaderfile.ExternalLinkageNotDeclaredInHeaderFile

class ExternalLinkageNotDeclaredInHeaderFileQuery extends ExternalLinkageNotDeclaredInHeaderFileSharedQuery
{
  ExternalLinkageNotDeclaredInHeaderFileQuery() {
    this = IncludesPackage::externalLinkageNotDeclaredInHeaderFileQuery()
  }
}
