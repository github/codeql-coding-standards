/**
 * @id c/misra/threading-object-with-invalid-storage-duration
 * @name RULE-22-13: Threading objects (mutexes, threads, etc). shall have not have automatic or thread storage duration
 * @description Thread objects, thread synchronization objects, and thread specific storage pointers
 *              shall have appropriate storage duration.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-22-13
 *       correctness
 *       concurrency
 *       external/misra/c/2012/amendment4
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.Objects
import codingstandards.cpp.Concurrency
import codingstandards.cpp.types.Resolve

from ObjectIdentity obj, StorageDuration storageDuration, Type type
where
  not isExcluded(obj, Concurrency8Package::threadingObjectWithInvalidStorageDurationQuery()) and
  storageDuration = obj.getStorageDuration() and
  not storageDuration.isStatic() and
  type = obj.getASubObjectType() and
  type instanceof ResolvesTo<C11ThreadingObjectType>::IgnoringSpecifiers
select obj,
  "Object of type '" + obj.getType().getName() + "' has invalid storage duration type '" +
    storageDuration.getStorageTypeName() + "'."
