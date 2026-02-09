/**
 * @id cpp/cert/offset-used-on-invalid-type-or-member
 * @name EXP59-CPP: Use offsetof() on valid types and members
 * @description Using offsetof() on a non-standard layout type results in undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/cert/id/exp59-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert

// Note: this query explicitly encodes some cases that do not compile with some
// compilers such as bit-field access and accessing static fields as the second
// argument of the offset. This query also omits member functions used as the
// argument since it doesn't compile under clang or msvc.
from BuiltInOperationBuiltInOffsetOf os
where
  not isExcluded(os, ClassesPackage::offsetUsedOnInvalidTypeOrMemberQuery()) and
  not exists(Class storageType, ValueFieldAccess field |
    storageType = os.getChild(0).getType() and
    field = os.getChild(1) and
    // must be standard layout
    storageType.isStandardLayout() and
    // field must not be static
    not field.getTarget().isStatic() and
    // field must not be a bit field
    not field.getTarget() instanceof BitField
  )
select os, "Usage of offsetof on a invalid storage class or member."
