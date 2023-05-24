/**
 * @id cpp/autosar/floating-point-implementation-shall-comply-with-ieee-standard
 * @name A0-4-1: Floating-point implementation shall comply with IEEE 754 standard
 * @description Floating-point arithmetic has a range of problems associated with it. Some of these
 *              can be overcome by using an implementation that conforms to IEEE 754 (IEEE Standard
 *              for Floating-Point Arithmetic).
 * @kind problem
 * @precision very-high
 * @problem.severity warning
 * @tags external/autosar/id/a0-4-1
 *       correctness
 *       maintainability
 *       external/autosar/allocated-target/infrastructure
 *       external/autosar/allocated-target/toolchain
 *       external/autosar/enforcement/non-automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar
import codingstandards.cpp.TypeUses

class NumericLimits extends Class {
  NumericLimits() { this.hasQualifiedName("std", ["numeric_limits", "__libcpp_numeric_limits"]) }

  /**
   * Gets the template argument specified for this type.
   */
  Type getType() { result = getTemplateArgument(0) }

  /**
   * Holds if the given type is IEC 559 compatible.
   */
  predicate isIec559() {
    exists(MemberVariable is_iec559 |
      is_iec559 = getAMemberVariable() and
      is_iec559.hasName("is_iec559") and
      // Constant of true
      is_iec559.getInitializer().getExpr().getValue() = "1"
    )
  }

  /** Gets the number of digits used for the significand. */
  int getSignificandDigits() {
    exists(MemberVariable digits |
      digits = getAMemberVariable() and
      digits.hasName("digits") and
      result = digits.getInitializer().getExpr().getValue().toInt()
    )
  }
}

/**
 * Holds if the floating point type is IEEE 754 compatible.
 */
predicate isIEEE754(FloatingPointType fp) {
  exists(NumericLimits nl |
    nl.getType() = fp and
    nl.isIec559()
  |
    // Based on examples in the rule, `float` not only needs to be IEC 559/IEEE 754 compliant,
    // but it must also comply with IEEE 754 requirements for a single precision float, which
    // requires 24 digits.
    fp instanceof FloatType and nl.getSignificandDigits() = 24
    or
    // Based on examples in the rule, `double` not only needs to be IEC 559/IEEE 754 compliant,
    // but it must also comply with IEEE 754 requirements for a double precision float, which
    // requires 53 digits.
    fp instanceof DoubleType and nl.getSignificandDigits() = 53
    or
    // Long double is permitted without any requirements on digit size
    fp instanceof LongDoubleType
  )
}

from FloatingPointType fp, Locatable l
where
  not isExcluded(l, ToolchainPackage::floatingPointImplementationShallComplyWithIeeeStandardQuery()) and
  not isIEEE754(fp) and
  l = getATypeUse(fp)
select l, "Use of floating point type that does not comply with IEEE 754"
