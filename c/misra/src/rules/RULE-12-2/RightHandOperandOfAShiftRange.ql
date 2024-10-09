/**
 * @id c/misra/right-hand-operand-of-a-shift-range
 * @name RULE-12-2: The right operand of a shift shall be smaller then the width in bits of the left operand
 * @description The right hand operand of a shift operator shall lie in the range zero to one less
 *              than the width in bits of the essential type of the left hand operand.
 * @kind problem
 * @precision very-high
 * @problem.severity error
 * @tags external/misra/id/rule-12-2
 *       correctness
 *       external/misra/c/2012/third-edition-first-revision
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.c.misra.EssentialTypes
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

class ShiftExpr extends BinaryBitwiseOperation {
  ShiftExpr() { this instanceof LShiftExpr or this instanceof RShiftExpr }
}

MacroInvocation getAMacroInvocation(ShiftExpr se) { result.getAnExpandedElement() = se }

Macro getPrimaryMacro(ShiftExpr se) {
  exists(MacroInvocation mi |
    mi = getAMacroInvocation(se) and
    not exists(MacroInvocation otherMi |
      otherMi = getAMacroInvocation(se) and otherMi.getParentInvocation() = mi
    ) and
    result = mi.getMacro()
  )
}

from
  ShiftExpr e, Expr right, int max_val, float lowerBound, float upperBound, Type essentialType,
  string extraMessage, Locatable optionalPlaceholderLocation, string optionalPlaceholderMessage
where
  not isExcluded(right, Contracts7Package::rightHandOperandOfAShiftRangeQuery()) and
  right = e.getRightOperand().getFullyConverted() and
  essentialType = getEssentialType(e.getLeftOperand()) and
  max_val = (8 * essentialType.getSize()) - 1 and
  upperBound = upperBound(right) and
  lowerBound = lowerBound(right) and
  (
    lowerBound < 0 or
    upperBound > max_val
  ) and
  // If this shift happens inside a macro, then report the macro as well
  // for easier validation
  (
    if exists(getPrimaryMacro(e))
    then
      extraMessage = " from expansion of macro $@" and
      exists(Macro m |
        m = getPrimaryMacro(e) and
        optionalPlaceholderLocation = m and
        optionalPlaceholderMessage = m.getName()
      )
    else (
      extraMessage = "" and
      optionalPlaceholderLocation = e and
      optionalPlaceholderMessage = ""
    )
  )
select right,
  "The possible range of the right operand of the shift operator (" + lowerBound + ".." + upperBound
    + ") is outside the the valid shift range (0.." + max_val +
    ") for the essential type of the left operand (" + essentialType + ")" + extraMessage + ".",
  optionalPlaceholderLocation, optionalPlaceholderMessage
