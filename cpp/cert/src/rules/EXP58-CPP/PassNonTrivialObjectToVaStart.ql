/**
 * @id cpp/cert/pass-non-trivial-object-to-va-start
 * @name EXP58-CPP: Pass a non-trivial object to va_start
 * @description Passing an object of an unsupported type as the second argument to va_start() can
 *              result in undefined behavior that might be exploited to cause data integrity
 *              violations.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/exp58-cpp
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

class NonTrivialClass extends Class {
  NonTrivialClass() {
    exists(CopyConstructor cc | cc.getDeclaringType() = this and not cc.isCompilerGenerated())
    or
    exists(MoveConstructor mc | mc.getDeclaringType() = this and not mc.isCompilerGenerated())
    or
    exists(Destructor d | d.getDeclaringType() = this and not d.isCompilerGenerated())
  }
}

from VariableAccess va
where
  not isExcluded(va, ExpressionsPackage::passNonTrivialObjectToVaStartQuery()) and
  va.getType() instanceof NonTrivialClass and
  exists(BuiltInVarArgsStart va_start | va_start.getLastNamedParameter() = va)
select va, "A non-trivial object is passed to 'va_start'."
