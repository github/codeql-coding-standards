/**
 * @id cpp/autosar/signed-val-passed-to-char
 * @name A21-8-1: Arguments to character-handling functions shall be representable as an unsigned char
 * @description Passing values which are not unsigned chars to character-handling functions can
 *              result in undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/autosar/id/a21-8-1
 *       correctness
 *       external/autosar/allocated-target/implementation
 *       external/autosar/enforcement/automated
 *       external/autosar/obligation/required
 */

import cpp
import codingstandards.cpp.autosar

/**
 * A character handling function declared in <cctype>
 */
class CTypeCharFunction extends Function {
  CTypeCharFunction() {
    hasGlobalOrStdName([
        "isalnum", "isalpha", "iscntrl", "isdigit", "isgraph", "islower", "isprint", "ispunct",
        "isspace", "isupper", "isxdigit", "toupper", "tolower"
      ])
  }
}

from FunctionCall call, CTypeCharFunction ctypeCharFunction
where
  not isExcluded(call, TypeRangesPackage::signedValPassedToCharQuery()) and
  call.getTarget() = ctypeCharFunction and
  // The rule requires an "explicit conversion to unsigned char". In practice, this "explicit
  // conversion" may not be local to this expression, and so it's sufficient for us to check that
  // after all explicit conversions the unspecified type is `unsigned char`.
  not call.getArgument(0).getExplicitlyConverted().getUnspecifiedType() instanceof UnsignedCharType
select call,
  "Argument to call to " + ctypeCharFunction.getName() +
    " is not explicitly cast to 'unsigned char'."
