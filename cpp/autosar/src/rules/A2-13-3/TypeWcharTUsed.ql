/**
 * @id cpp/autosar/type-wchar-t-used
 * @name A2-13-3: Type wchar_t shall not be used
 * @description Type wchar_t shall not be used because its width is implementation defined.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-13-3
 *       correctness
 *       readability
 *       scope/single-translation-unit
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

predicate isUsingWideCharType(ClassTemplateInstantiation c) {
  c.getTemplateArgument(_) instanceof WideCharType or
  isUsingWideCharType(c.getTemplateArgument(_))
}

from Variable v
where
  not isExcluded(v, BannedTypesPackage::typeWcharTUsedQuery()) and
  (
    v.getUnderlyingType() instanceof WideCharType and
    not v.isFromTemplateInstantiation(_)
    or
    exists(ClassTemplateInstantiation c |
      c = v.getType() and
      isUsingWideCharType(c)
    )
  )
select v, "Use of wchar_t type."
