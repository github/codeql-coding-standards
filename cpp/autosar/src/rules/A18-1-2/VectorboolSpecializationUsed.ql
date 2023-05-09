/**
 * @id cpp/autosar/vectorbool-specialization-used
 * @name A18-1-2: The std::vector<bool> specialization shall not be used
 * @description The std::vector<bool> specialization differs from all other containers
 *              std::vector<T> such that sizeof bool is implementation defined which causes errors
 *              when using some STL algorithms.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a18-1-2
 *       correctness
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.StdNamespace

predicate isVectorBool(ClassTemplateInstantiation c) {
  c.getNamespace() instanceof StdNS and
  c.getTemplateArgument(0) instanceof BoolType and
  c.getSimpleName() = "vector"
}

predicate isUsingVectorBool(ClassTemplateInstantiation c) {
  isVectorBool(c) or
  isUsingVectorBool(c.getTemplateArgument(_))
}

from Variable v, ClassTemplateInstantiation c
where
  v.getUnderlyingType() = c and
  not v.isFromTemplateInstantiation(_) and
  isUsingVectorBool(c) and
  not isExcluded(v, BannedTypesPackage::vectorboolSpecializationUsedQuery())
select v, "Use of std::vector<bool> specialization."
