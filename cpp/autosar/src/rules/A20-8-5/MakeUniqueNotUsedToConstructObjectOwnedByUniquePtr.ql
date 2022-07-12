/**
 * @id cpp/autosar/make-unique-not-used-to-construct-object-owned-by-unique-ptr
 * @name A20-8-5: std::make_unique shall be used to construct objects owned by std::unique_ptr
 * @description Using std::make_unique avoids explicit calls to 'new' and provides a safe way to
 *              allocate objects managed by std::unique_ptr.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a20-8-5
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers

from AutosarUniquePointer up, ConstructorCall cc
where
  not isExcluded(cc,
    SmartPointers1Package::makeUniqueNotUsedToConstructObjectOwnedByUniquePtrQuery()) and
  cc = up.getAConstructorCallWithExternalObjectConstruction()
select cc, "Object owned by std::unique_ptr is not constructed by std::make_unique."
