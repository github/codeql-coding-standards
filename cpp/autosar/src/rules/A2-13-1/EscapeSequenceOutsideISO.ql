/**
 * @id cpp/autosar/escape-sequence-outside-iso
 * @name A2-13-1: Only those escape sequences that are defined in ISO/IEC 14882:2014 shall be used
 * @description The use of an undefined escape sequence leads to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a2-13-1
 *       correctness
 *       coding-standards/baseline/safety
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.rules.backslashcharactermisuse.BackslashCharacterMisuse

class EscapeSequenceOutsideISOQuery extends BackslashCharacterMisuseSharedQuery {
  EscapeSequenceOutsideISOQuery() { this = LiteralsPackage::escapeSequenceOutsideISOQuery() }
}
