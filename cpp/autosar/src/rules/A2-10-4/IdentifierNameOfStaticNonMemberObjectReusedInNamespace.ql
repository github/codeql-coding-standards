/**
 * @id cpp/autosar/identifier-name-of-static-non-member-object-reused-in-namespace
 * @name A2-10-4: Reuse of identifier name of a non-member static object within a namespace
 * @description The identifier name of a non-member object with static storage duration shall not be
 *              reused within a namespace.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a2-10-4
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

class CandidateVariable extends Variable {
  CandidateVariable() {
    hasDefinition() and
    isStatic() and
    not this instanceof MemberVariable
  }
}

from CandidateVariable v1, CandidateVariable v2
where
  not isExcluded(v1, NamingPackage::identifierNameOfStaticNonMemberObjectReusedInNamespaceQuery()) and
  not isExcluded(v2, NamingPackage::identifierNameOfStaticNonMemberObjectReusedInNamespaceQuery()) and
  not v1 = v2 and
  v1.getQualifiedName() = v2.getQualifiedName()
select v2, "Non-member static object $@ reuses identifier name of non-member static object $@", v2,
  v2.getName(), v1, v1.getName()
