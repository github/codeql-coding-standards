/**
 * @id cpp/autosar/basic-string-may-not-be-null-terminated-autosar
 * @name A27-0-2: A C-style string shall guarantee sufficient space for data and the null terminator
 * @description The C++ string constructor will only terminate a C-Style string if the C-Style
 *              string is also null terminated.
 * @kind problem
 * @precision very-high
 * @problem.severity recommendation
 * @tags external/autosar/id/a27-0-2
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/advisory
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.basicstringmaynotbenullterminated.BasicStringMayNotBeNullTerminated

class BasicStringMayNotBeNullTerminatedAutosar extends BasicStringMayNotBeNullTerminatedSharedQuery {
  BasicStringMayNotBeNullTerminatedAutosar() {
    this = StringsPackage::basicStringMayNotBeNullTerminatedAutosarQuery()
  }
}
