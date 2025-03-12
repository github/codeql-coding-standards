/**
 * @id c/misra/thread-local-object-address-copied-to-global-object
 * @name RULE-18-6: The address of an object with thread-local storage shall not be copied to a global object
 * @description Storing the address of a thread-local object in a global object will result in
 *              undefined behavior if the address is accessed after the relevant thread is
 *              terminated.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-18-6
 *       correctness
 *       external/misra/c/2012/amendment3
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Objects
import codingstandards.cpp.Concurrency

from AssignExpr assignment, Element threadLocal, ObjectIdentity static
where
  not isExcluded(assignment, Pointers1Package::threadLocalObjectAddressCopiedToGlobalObjectQuery()) and
  assignment.getLValue() = static.getASubobjectAccess() and
  static.getStorageDuration().isStatic() and
  (
    exists(ObjectIdentity threadLocalObj |
      threadLocal = threadLocalObj and
      assignment.getRValue() = threadLocalObj.getASubobjectAddressExpr() and
      threadLocalObj.getStorageDuration().isThread()
    )
    or
    exists(TSSGetFunctionCall getCall |
      threadLocal = getCall.getKey() and
      assignment.getRValue() = getCall
    )
  )
select assignment, "Thread local object $@ address copied to static object $@.",
  threadLocal.getLocation(), threadLocal.toString(), static.getLocation(), static.toString()
