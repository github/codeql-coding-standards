import cpp
import semmle.code.cpp.dataflow.DataFlow
import codingstandards.cpp.standardlibrary.FileAccess

/**
 * any call to function `feof()` or `ferror()`
 */
abstract class FeofFerrorCall extends FileAccess {
  override VariableAccess getFileExpr() {
    result = [this.getArgument(0), this.getArgument(0).(AddressOfExpr).getAnOperand()]
  }
}

class FeofCall extends FeofFerrorCall {
  FeofCall() { this.getTarget().hasGlobalName("feof") }
}

class FerrorCall extends FeofFerrorCall {
  FerrorCall() { this.getTarget().hasGlobalName("ferror") }
}

predicate isShortCircuitedEdge(ControlFlowNode fst, ControlFlowNode snd) {
  fst = any(LogicalAndExpr andOp).getLeftOperand() and snd = fst.getAFalseSuccessor()
  or
  fst = any(LogicalOrExpr orOp).getLeftOperand() and snd = fst.getATrueSuccessor()
}

// Nodes following a file read before a call to `feof/ferror` is performed
ControlFlowNode feofUnchecked(InBandErrorReadFunctionCall read) {
  result = read
  or
  exists(ControlFlowNode mid |
    mid = feofUnchecked(read) and
    //do not traverse the short-circuited CFG edge
    not isShortCircuitedEdge(mid, result) and
    result = mid.getASuccessor() and
    //Stop recursion on call to feof/ferror on the correct file
    not sameFileSource(result.(FeofCall), read)
  )
}

// Nodes following a file read before a call to `feof` is performed
ControlFlowNode ferrorUnchecked(InBandErrorReadFunctionCall read) {
  result = read
  or
  exists(ControlFlowNode mid |
    mid = ferrorUnchecked(read) and
    //do not traverse the short-circuited CFG edge
    not isShortCircuitedEdge(mid, result) and
    result = mid.getASuccessor() and
    //Stop recursion on call to ferror on the correct file
    not sameFileSource(result.(FerrorCall), read)
  )
}

// No feof() or ferror() checks are performed after the function reads from a file
predicate missingFeofFerrorChecks(InBandErrorReadFunctionCall read) {
  read.getEnclosingFunction() = feofUnchecked(read)
  or
  read.getEnclosingFunction() = ferrorUnchecked(read)
}

abstract class EOFWEOFInvocation extends MacroInvocation {
  abstract Type getRequiredType();
}

class EOFInvocation extends EOFWEOFInvocation {
  EOFInvocation() { this.getMacroName() = "EOF" }

  override Type getRequiredType() { result instanceof IntType }
}

class WEOFInvocation extends EOFWEOFInvocation {
  WEOFInvocation() { this.getMacroName() = "WEOF" }

  override Type getRequiredType() { result instanceof Wint_t }
}

// The equality operation `eq` checks a char fetched from `read` against a macro
predicate isMacroCheck(EqualityOperation eq, InBandErrorReadFunctionCall read) {
  exists(Expr c, EOFWEOFInvocation mi |
    // one operand is the char c fetched from `read`
    c = eq.getAnOperand() and
    // an operand is an invocation of the EOF macro
    mi.getAGeneratedElement() = eq.getAnOperand() and
    DataFlow::localExprFlow(read, c) and
    // c is of the appropriate type `int`/`wint_t`
    c.getUnderlyingType() = mi.getRequiredType()
  )
}

// Nodes following a file read before a EOF/WEOF macro is checked
ControlFlowNode macroUnchecked(InBandErrorReadFunctionCall read) {
  result = read.getASuccessor()
  or
  exists(ControlFlowNode mid |
    mid = macroUnchecked(read) and
    //do not traverse the short-circuited CFG edge
    not isShortCircuitedEdge(mid, result) and
    result = mid.getASuccessor() and
    // Stop recursion on a correct comparison of the fetched char against EOF/WEOF
    not isMacroCheck(result, read)
  )
}

// No checks for comparison to EOF/WEOF are performed after the function reads from a file
predicate missingEOFWEOFChecks(InBandErrorReadFunctionCall read) {
  // no comparison against EOF along one path
  read.getEnclosingFunction() = macroUnchecked(read)
  or
  // another char is read before the comparison to EOF
  exists(FileReadFunctionCall fc |
    macroUnchecked(read) = fc and
    sameFileSource(read, fc)
  )
}
