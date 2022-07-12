/**
 * @id cpp/autosar/type-defined-as-struct-has-only-public-data-members
 * @name A11-0-2: A type defined as struct shall provide only public data members
 * @description It is consistent with developer expectations that a struct is only an aggregate data
 *              type, without class-like features.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a11-0-2
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import NonUnionStruct

class NonCompilerGeneratedField extends Field {
  NonCompilerGeneratedField() { not this.isCompilerGenerated() }
}

from NonUnionStruct s, Declaration d
where
  not isExcluded(s, ClassesPackage::typeDefinedAsStructHasOnlyPublicDataMembersQuery()) and
  not isExcluded(d, ClassesPackage::typeDefinedAsStructHasOnlyPublicDataMembersQuery()) and
  d = s.getAMember() and
  // | P: d instanceof Field | Q: s.getAPublicMember() = d | P => Q | ~ (P => Q) |
  // |-----------------------|-----------------------------|--------|------------|
  // | T                     | T                           | T      | F          |
  // | T                     | F                           | F      | T          | << this is the case we flag
  // | F                     | T                           | T      | F          |
  // | F                     | F                           | T      | F          |
  not (d instanceof NonCompilerGeneratedField implies s.getAPublicMember() = d)
select d, "Field $@ of struct $@ is not public.", d, d.getName(), s, s.getName()
