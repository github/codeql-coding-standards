/**
 * @id c/cert/do-not-pass-aliased-pointer-to-restrict-qualified-param
 * @name EXP43-C: Do not pass aliased pointers to restrict-qualified parameters
 * @description Passing an aliased pointer to a restrict-qualified parameter is undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/cert/id/exp43-c
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.donotpassaliasedpointertorestrictqualifiedparamshared.DoNotPassAliasedPointerToRestrictQualifiedParamShared

class DoNotPassAliasedPointerToRestrictQualifiedParamQuery extends DoNotPassAliasedPointerToRestrictQualifiedParamSharedSharedQuery
{
  DoNotPassAliasedPointerToRestrictQualifiedParamQuery() {
    this = Pointers3Package::doNotPassAliasedPointerToRestrictQualifiedParamQuery()
  }
}
