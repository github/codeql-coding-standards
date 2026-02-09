/**
 * @id cpp/cert/cast-of-pointer-to-incomplete-class
 * @name EXP57-CPP: Do not cast pointers to incomplete classes
 * @description Do not cast pointer to incomplete classes to prevent undefined behavior when the
 *              resulting pointer is dereferenced.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/exp57-cpp
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
import codingstandards.cpp.Type

from Cast cast, IncompleteType incompleteType
where
  not isExcluded(cast, PointersPackage::castOfPointerToIncompleteClassQuery()) and
  cast.getUnderlyingType().(PointerType).getBaseType() = incompleteType and
  not cast.isCompilerGenerated()
select cast, "Cast of pointer to incomplete class $@.", incompleteType, incompleteType.getName()
