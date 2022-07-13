/**
 * @id cpp/autosar/make-shared-not-used-to-construct-object-owned-by-shared-ptr
 * @name A20-8-6: std::make_shared shall be used to construct objects owned by std::shared_ptr
 * @description Using std::make_shared avoids explicit calls to 'new' and provides a safe way to
 *              allocate objects managed by std::shared_ptr.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a20-8-6
 *       maintainability
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.SmartPointers

from AutosarSharedPointer sp, ConstructorCall cc
where
  not isExcluded(cc,
    SmartPointers1Package::makeSharedNotUsedToConstructObjectOwnedBySharedPtrQuery()) and
  cc = sp.getAConstructorCallWithExternalObjectConstruction()
select cc, "Object owned by std::shared_ptr is not constructed by std::make_shared."
