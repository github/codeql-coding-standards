/**
 * @id c/cert/do-not-modify-objects-with-temporary-lifetime
 * @name EXP35-C: Do not modify objects with temporary lifetime
 * @description Attempting to modify an object with temporary lifetime results in undefined
 *              behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/exp35-c
 *       correctness
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import codingstandards.c.Objects

// Note: Undefined behavior is possible regardless of whether the accessed field from the returned
// struct is an array or a scalar (i.e. arithmetic and pointer types) member, according to the standard.
from FieldAccess fa, TemporaryObjectIdentity tempObject
where
  not isExcluded(fa, InvalidMemory2Package::doNotModifyObjectsWithTemporaryLifetimeQuery()) and
  fa.getQualifier().getUnconverted() = tempObject
select fa, "Field access on $@ qualifier occurs after its temporary object lifetime.", tempObject,
  "temporary object"
