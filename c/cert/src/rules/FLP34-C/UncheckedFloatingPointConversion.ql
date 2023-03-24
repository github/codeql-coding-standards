/**
 * @id c/cert/unchecked-floating-point-conversion
 * @name FLP34-C: Ensure that floating-point conversions are within range of the new type
 * @description Conversions of out-of-range floating-point values to integral types can lead to
 *              undefined behavior.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/cert/id/flp34-c
 *       correctness
 *       external/cert/obligation/rule
 */

import cpp
import codingstandards.c.cert
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis
import semmle.code.cpp.controlflow.Guards

/*
 * There are three cases to consider under this rule:
 *  1) Float-to-int
 *  2) Narrowing float-to-float conversions
 *  3) Int-to-float
 *
 * The first results in undefined behaviour if the float is outside the range of the int, and is
 * the topic of this query.
 *
 * The second two cases only cause undefined behaviour if the floating point format does not
 * support -inf/+inf. This information is not definitively present in the CodeQL database. The
 * macro INFINITY in principle differs in the two cases, but we are unable to distinguish one case
 * from the other.
 *
 * (2) and (3) do not appear to be problems in practice on the hardware targets and compilers we
 * support, because they all provide +inf and -inf unconditionally.
 */

/**
 * A function whose name is suggestive that it counts the number of bits set.
 */
class PopCount extends Function {
  PopCount() { this.getName().toLowerCase().matches("%popc%nt%") }
}

/**
 * A macro which is suggestive that it is used to determine the precision of an integer.
 */
class PrecisionMacro extends Macro {
  PrecisionMacro() { this.getName().toLowerCase().matches("precision") }
}

bindingset[value]
predicate withinIntegralRange(IntegralType typ, float value) {
  exists(float lb, float ub, float limit |
    limit = 2.pow(8 * typ.getSize()) and
    (
      if typ.isUnsigned()
      then (
        lb = 0 and ub = limit - 1
      ) else (
        lb = -limit / 2 and
        ub = (limit / 2) - 1
      )
    ) and
    value >= lb and
    value <= ub
  )
}

from FloatingPointToIntegralConversion c, ArithmeticType underlyingTypeAfter
where
  not isExcluded(c, FloatingTypesPackage::uncheckedFloatingPointConversionQuery()) and
  underlyingTypeAfter = c.getUnderlyingType() and
  not (
    // Either the upper or lower bound of the expression is outside the range of the new type
    withinIntegralRange(underlyingTypeAfter, [upperBound(c.getExpr()), lowerBound(c.getExpr())])
    or
    // Heuristic - is there are guard the abs value of the float can fit in the precision of an int?
    exists(GuardCondition gc, FunctionCall log2, FunctionCall fabs, Expr precision |
      // gc.controls(c, false) and
      log2.getTarget().hasGlobalOrStdName("log2" + ["", "l", "f"]) and
      fabs.getTarget().hasGlobalOrStdName("fabs" + ["", "l", "f"]) and
      log2.getArgument(0) = fabs and
      // Precision is either a macro expansion or function call
      (
        precision.(FunctionCall).getTarget() instanceof PopCount
        or
        precision = any(PrecisionMacro pm).getAnInvocation().getExpr()
      ) and
      gc.ensuresLt(precision, log2, 0, c.getExpr().getBasicBlock(), false)
    )
  )
select c, "Conversion of float to integer without appropriate guards avoiding undefined behavior."
