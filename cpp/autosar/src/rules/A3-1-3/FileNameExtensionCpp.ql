/**
 * @id cpp/autosar/file-name-extension-cpp
 * @name A3-1-3: Implementation files, that are defined locally in the project, should have a file name extension of ".cpp"
 * @description Using any implementation file extension other than ".cpp" makes project structure
 *              harder to understand.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a3-1-3
 *       maintainability
 *       readability
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar

from Compilation c, File file
where
  file = c.getAFileCompiled() and
  not file.getExtension() = "cpp" and
  not isExcluded(file, IncludesPackage::fileNameExtensionCppQuery())
select file,
  "Implementation file " + file.getBaseName() + " has a file extension of " + file.getExtension() +
    " instead of cpp."
