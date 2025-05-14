/**
 * @id cpp/cert/remove-const-or-volatile-qualification-cert
 * @name EXP55-CPP: Do not access a cv-qualified object through a cv-unqualified type
 * @description Removing `const`/`volatile` qualification can result in undefined behavior when a
 *              `const`/`volatile` qualified object is modified through a non-const access path.
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/cert/id/exp55-cpp
 *       correctness
 *       external/cert/severity/medium
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p8
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.removeconstorvolatilequalification.RemoveConstOrVolatileQualification

class RemoveConstOrVolatileQualificationCertQuery extends RemoveConstOrVolatileQualificationSharedQuery
{
  RemoveConstOrVolatileQualificationCertQuery() {
    this = ConstPackage::removeConstOrVolatileQualificationCertQuery()
  }
}
