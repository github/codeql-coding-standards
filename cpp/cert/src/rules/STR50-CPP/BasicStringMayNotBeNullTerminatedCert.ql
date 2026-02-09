/**
 * @id cpp/cert/basic-string-may-not-be-null-terminated-cert
 * @name STR50-CPP: A C-style string shall guarantee sufficient space for data and the null terminator
 * @description The C++ string constructor will only terminate a C-Style string if the C-Style
 *              string is also null terminated.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/cert/id/str50-cpp
 *       external/cert/severity/high
 *       external/cert/likelihood/likely
 *       external/cert/remediation-cost/medium
 *       external/cert/priority/p18
 *       external/cert/level/l1
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.cpp.cert
import codingstandards.cpp.rules.basicstringmaynotbenullterminated.BasicStringMayNotBeNullTerminated

class BasicStringMayNotBeNullTerminatedCertQuery extends BasicStringMayNotBeNullTerminatedSharedQuery
{
  BasicStringMayNotBeNullTerminatedCertQuery() {
    this = StringsPackage::basicStringMayNotBeNullTerminatedCertQuery()
  }
}
