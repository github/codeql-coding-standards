/**
 * @id cpp/autosar/do-not-pass-aliased-pointer-to-restrict-qualified-param
 * @name M0-2-1: Do not pass aliased pointers as parameters of functions where it is undefined behaviour for those pointers to overlap
 * @description Passing an aliased pointer to a conceptually restrict-qualified parameter is
 *              undefined behavior.
 * @kind problem
 * @precision medium
 * @problem.severity error
 * @tags external/autosar/id/m0-2-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.donotpassaliasedpointertorestrictqualifiedparam_shared.DoNotPassAliasedPointerToRestrictQualifiedParam_Shared

class DoNotPassAliasedPointerToRestrictQualifiedParamQuery extends DoNotPassAliasedPointerToRestrictQualifiedParam_SharedSharedQuery {
  DoNotPassAliasedPointerToRestrictQualifiedParamQuery() {
    this = RepresentationPackage::doNotPassAliasedPointerToRestrictQualifiedParamQuery()
  }
}
