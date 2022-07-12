/**
 * @id cpp/autosar/escape-sequence-outside-iso
 * @name A2-13-1: Only those escape sequences that are defined in ISO/IEC 14882:2014 shall be used
 * @description The use of an undefined escape sequence leads to undefined behavior.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/autosar/id/a2-13-1
 *       correctness
 *       external/autosar/allocated-target/architecture
 *       external/autosar/allocated-target/design
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

from StringLiteral l, string es
where
  not isExcluded(l, LiteralsPackage::escapeSequenceOutsideISOQuery()) and
  es = l.getANonStandardEscapeSequence(_, _) and
  // Exclude universal-character-names, which begin with \u or \U
  not es.toLowerCase().matches("\\u")
select l, "This literal contains the non-standard escape sequence " + es + "."
