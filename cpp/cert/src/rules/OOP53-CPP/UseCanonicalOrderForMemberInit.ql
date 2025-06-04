/**
 * @id cpp/cert/use-canonical-order-for-member-init
 * @name OOP53-CPP: Write constructor member initializers in the canonical order
 * @description Writing constructor intializers out-of-order can lead to developer confusion over
 *              the order of initialization, which can result to reading uninitialized memory and
 *              therefore undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity warning
 * @tags external/cert/id/oop53-cpp
 *       correctness
 *       security
 *       maintainability
 *       readability
 *       external/cert/severity/medium
 *       external/cert/likelihood/unlikely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.usecanonicalorderformemberinit.UseCanonicalOrderForMemberInit

class UseCanonicalOrderForMemberInitQuery extends UseCanonicalOrderForMemberInitSharedQuery {
  UseCanonicalOrderForMemberInitQuery() {
    this = InitializationPackage::useCanonicalOrderForMemberInitQuery()
  }
}
