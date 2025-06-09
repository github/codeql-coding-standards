/**
 * @id cpp/cert/do-not-attempt-to-create-a-string-from-a-null-pointer
 * @name STR51-CPP: Do not attempt to create a std::string from a null pointer
 * @description Creating a std::string from a null pointer leads to undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/str51-cpp
 *       correctness
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.lifetimes.lifetimeprofile.LifetimeProfile
import codingstandards.cpp.Dereferenced

from NullDereference nd, NullReason nr, string message, Element explanation, string explanationDesc
where
  not isExcluded(nd, NullPackage::doNotAttemptToCreateAStringFromANullPointerQuery()) and
  nd instanceof BasicStringDereferencedExpr and
  nr = nd.getAnInvalidReason() and
  nr.hasMessage(message, explanation, explanationDesc)
select nd, "Null may be dereferenced here " + message, explanation, explanationDesc
