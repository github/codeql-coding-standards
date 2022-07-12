/**
 * @id cpp/autosar/header-file-expected-file-name-extension
 * @name A3-1-2: Header files, that are defined locally in the project, shall have a file name extension of one of: ".h", ".hpp" or ".hxx"
 * @description Using any header file extension other than: ".h", ".hpp" or ".hxx" makes code harder
 *              to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-1-2
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.AcceptableHeader

from Include inc, File file
//if header files are not included they will not be considered relevant
where
  file = inc.getIncludedFile() and
  not file instanceof AcceptableHeader and
  not isExcluded(file, IncludesPackage::headerFileExpectedFileNameExtensionQuery())
select file,
  "File " + file.getBaseName() + " is $@ but has the non header extension '" + file.getExtension() +
    "'.", inc, "included"
