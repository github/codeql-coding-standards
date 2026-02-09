/**
 * @id cpp/cert/do-not-use-setjmp-or-longjmp
 * @name ERR52-CPP: Do not use setjmp() or longjmp()
 * @description Do not use setjmp() or longjmp().
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/cert/id/err52-cpp
 *       correctness
 *       scope/single-translation-unit
 *       external/cert/severity/low
 *       external/cert/likelihood/probable
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p4
 *       external/cert/level/l3
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.donotusesetjmporlongjmpshared.DoNotUseSetjmpOrLongjmpShared

class DoNotUseSetjmpOrLongjmpQuery extends DoNotUseSetjmpOrLongjmpSharedSharedQuery {
  DoNotUseSetjmpOrLongjmpQuery() { this = BannedFunctionsPackage::doNotUseSetjmpOrLongjmpQuery() }
}
