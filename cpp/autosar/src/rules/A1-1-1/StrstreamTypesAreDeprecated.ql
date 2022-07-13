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
import codingstandards.cpp.TypeUses

from Class c, Locatable l
where
  not isExcluded(l, ToolchainPackage::strstreamTypesAreDeprecatedQuery()) and
  c.hasQualifiedName("std", ["strstreambuf", "ostrstream", "istrstream"]) and
  exists(Type t | t = c | l = getATypeUse(t))
select l, "Use of <strstream> class '" + c.getQualifiedName() + "' is deprecated."
