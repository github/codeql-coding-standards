/**
 * @id cpp/autosar/auto-ptr-type-used
 * @name A18-1-3: The std::auto_ptr type shall not be used
 * @description The std::auto_ptr type is deprecated because it cannot be placed in STL containers.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a18-1-3
 *       maintainability
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.StdNamespace

predicate isAutoPtr(ClassTemplateInstantiation c) {
  c.getNamespace() instanceof StdNS and
  c.getSimpleName() = "auto_ptr"
}

predicate isUsingAutoPtr(ClassTemplateInstantiation c) {
  isAutoPtr(c) or
  isUsingAutoPtr(c.getTemplateArgument(_))
}

from Variable v, ClassTemplateInstantiation c
where
  v.getUnderlyingType() = c and
  not v.isFromTemplateInstantiation(_) and
  isUsingAutoPtr(c) and
  not isExcluded(v, BannedTypesPackage::autoPtrTypeUsedQuery())
select v, "Use of std::auto_ptr."
