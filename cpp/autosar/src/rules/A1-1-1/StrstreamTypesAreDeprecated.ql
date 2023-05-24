/**
 * @id cpp/autosar/strstream-types-are-deprecated
 * @name A1-1-1: std::strstreambuf, std::istrstream, and std::ostrstream are deprecated
 * @description std::strstreambuf, std::istrstream, and std::ostrstream are deprecated.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/autosar/id/a1-1-1
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from TypeMention l, Class c
where
  not isExcluded(l, ToolchainPackage::strstreamTypesAreDeprecatedQuery()) and
  c.hasQualifiedName("std", ["strstreambuf", "ostrstream", "istrstream"]) and
  l.getMentionedType() = c
select l, "Use of <strstream> class '" + c.getName() + "' is deprecated."
