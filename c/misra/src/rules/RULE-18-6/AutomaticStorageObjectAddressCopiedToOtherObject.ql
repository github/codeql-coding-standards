/**
 * @id c/misra/automatic-storage-object-address-copied-to-other-object
 * @name RULE-18-6: The address of an object with automatic storage shall not be copied to another object that persists
 * @description Storing the address of an object in a new object that persists past the original
 *              object's lifetime results in undefined behaviour if the address is subsequently
 *              accessed.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-6
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.rules.donotcopyaddressofautostorageobjecttootherobject.DoNotCopyAddressOfAutoStorageObjectToOtherObject

class AutomaticStorageObjectAddressCopiedToOtherObjectQuery extends DoNotCopyAddressOfAutoStorageObjectToOtherObjectSharedQuery {
  AutomaticStorageObjectAddressCopiedToOtherObjectQuery() {
    this = Pointers1Package::automaticStorageObjectAddressCopiedToOtherObjectQuery()
  }
}
