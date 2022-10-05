/**
 * @id cpp/autosar/identifier-name-of-a-non-member-object-with-external-or-internal-linkage-is-reused
 * @name A2-10-5: Reuse of identifier name of a non-member object with external or internal linkage
 * @description An identifier name of a non-member object with external or internal linkage should
 *              not be reused anywhere in the source code.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a2-10-5
 *       readability
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.Linkage

class NonMemberObjectWithLinkage extends Variable {
  NonMemberObjectWithLinkage() {
    not this instanceof MemberVariable and
    (hasExternalLinkage(this) or hasInternalLinkage(this))
  }
}

from NonMemberObjectWithLinkage o1, NonMemberObjectWithLinkage o2
where
  not isExcluded(o1,
    NamingPackage::identifierNameOfANonMemberObjectWithExternalOrInternalLinkageIsReusedQuery()) and
  not isExcluded(o2,
    NamingPackage::identifierNameOfANonMemberObjectWithExternalOrInternalLinkageIsReusedQuery()) and
  not o1 = o2 and
  o1.getName() = o2.getName() and
  // Only consider variables from uninstantiated templates, to avoid false positives where o1 and
  // o2 are the same object across different template instantiations
  not o1.isFromTemplateInstantiation(_) and
  not o2.isFromTemplateInstantiation(_)
select o2,
  "Identifier name of non-member object $@ reuses the identifier name of non-member object $@.", o2,
  o2.getName(), o1, o1.getName()
