/**
 * @id c/misra/eof-shall-be-compared-with-unmodified-return-values
 * @name RULE-22-7: The macro EOF shall only be compared with the unmodified return value from any Standard Library
 * @description The macro EOF shall only be compared with the unmodified return value from any
 *              Standard Library function capable of returning EOF.
 * @kind problem
 * @precision high
 * @problem.severity error
 * @tags external/misra/id/rule-22-7
 *       correctness
 *       external/misra/obligation/required
 */

import cpp
import codingstandards.c.misra
import codingstandards.cpp.ReadErrorsAndEOF

/**
 * The getchar() return value propagates directly to a check against EOF macro
 * type conversions are not allowed
 */
class DFConf extends DataFlow::Configuration {
  DFConf() { this = "DFConf" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof InBandErrorReadFunctionCall
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(EOFWEOFInvocation mi, EqualityOperation eq |
      // one operand is the sink
      sink.asExpr() = eq.getAnOperand() and
      // one operand is an invocation of the EOF macro
      mi.getAGeneratedElement() = eq.getAnOperand()
    )
  }

  override predicate isBarrier(DataFlow::Node barrier) {
    barrier.asExpr() = any(IntegralConversion c).getExpr()
  }
}

// The equality operation `eq` checks a char fetched from `read` against a macro
predicate isWeakMacroCheck(EqualityOperation eq, InBandErrorReadFunctionCall read) {
  exists(Expr c, EOFWEOFInvocation mi |
    // one operand is the char c fetched from `read`
    c = eq.getAnOperand() and
    // an operand is an invocation of the EOF macro
    mi.getAGeneratedElement() = eq.getAnOperand() and
    DataFlow::localExprFlow(read, c)
  )
}

from EqualityOperation eq, InBandErrorReadFunctionCall read, DFConf dfConf
where
  not isExcluded(eq, IO3Package::eofShallBeComparedWithUnmodifiedReturnValuesQuery()) and
  isWeakMacroCheck(eq, read) and
  not dfConf.hasFlow(DataFlow::exprNode(read), DataFlow::exprNode(eq.getAnOperand()))
select eq, "The check is not reliable as the type of the return value of $@ is converted.", read,
  read.toString()
