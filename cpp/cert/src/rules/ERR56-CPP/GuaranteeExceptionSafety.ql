/**
 * @id cpp/cert/guarantee-exception-safety
 * @name ERR56-CPP: Guarantee exception safety
 * @description Guarantee exception safety.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/err56-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/high
 *       external/cert/priority/p9
 *       external/cert/level/l2
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.exceptionsafetyguarantees.ExceptionSafetyGuarantees

class GuaranteeExceptionSafetyQuery extends ExceptionSafetyGuaranteesSharedQuery {
  GuaranteeExceptionSafetyQuery() { this = ExceptionSafetyPackage::guaranteeExceptionSafetyQuery() }
}
