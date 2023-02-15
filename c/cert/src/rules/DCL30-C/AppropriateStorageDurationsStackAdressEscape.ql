/**
 * @id c/cert/appropriate-storage-durations-stack-adress-escape
 * @name DCL30-C: Declare objects with appropriate storage durations
 * @description When storage durations are not compatible between assigned pointers it can lead to
 *              referring to objects outside of their lifetime, which is undefined behaviour.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/dcl30-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.cpp.rules.donotcopyaddressofautostorageobjecttootherobject.DoNotCopyAddressOfAutoStorageObjectToOtherObject

class AppropriateStorageDurationsStackAdressEscapeQuery extends DoNotCopyAddressOfAutoStorageObjectToOtherObjectSharedQuery {
  AppropriateStorageDurationsStackAdressEscapeQuery() {
    this = Declarations8Package::appropriateStorageDurationsStackAdressEscapeQuery()
  }
}
