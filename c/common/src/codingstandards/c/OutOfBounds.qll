/**
 * This module provides classes and predicates for analyzing the size of buffers
 * or objects from their base or a byte-offset, and identifying the potential for
 * expressions accessing those buffers to overflow.
 */

import cpp
import codingstandards.c.Pointers
import codingstandards.c.Variable
import codingstandards.cpp.Allocations
import codingstandards.cpp.Overflow
import codingstandards.cpp.PossiblyUnsafeStringOperation
import codingstandards.cpp.SimpleRangeAnalysisCustomizations
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.valuenumbering.GlobalValueNumbering
import semmle.code.cpp.security.BufferAccess

module OutOfBounds {
  bindingset[name, result]
  private string getNameOrInternalName(string name) {
    name.regexpMatch("__.*_+(?:" + result + ")")
  }

  /**
   * MISRA-C Rule 21.17 function table of names and parameter indices
   * which covers functions from <string.h> that rely on null-terminated strings.
   * 
   * This table is a subset of `libraryFunctionNameParamTable`.
   *
   * Note: These functions do not share a common semantic pattern of source and destination
   * parameters with the other functions explicitly defined in `libraryFunctionNameParamTable`,
   * although they do share a common issue of parsing non-null-terminated strings.
   * The `NullTerminatedStringBufferAccessLibraryFunction` base class provides an appropriate
   * interface for analyzing the functions in the below table.
   */
  private Function libraryFunctionNameParamTableSimpleString(string name, 
    int dst, int src, int src_sz, int dst_sz) 
  {
    result.hasGlobalOrStdName(name) and
    src_sz = -1 and 
    dst_sz = -1 and
    (
      name = "strcat" and
      dst = 0 and
      src = 1
      or
      name = "strchr" and
      dst = -1 and
      src = 0
      or
      name = ["strcmp", "strcoll"]  and
      dst = -1 and
      src = [0, 1]
      or
      name = "strcpy" and
      dst = 0 and
      src = 1
      or
      name = "strcspn" and
      dst = -1 and
      src = [0, 1]
      or
      name = "strlen" and
      dst = -1 and
      src = 0
      or
      name = "strpbrk" and
      dst = -1 and
      src = [0, 1]
      or
      name = "strrchr" and
      dst = -1 and
      src = 0
      or
      name = "strspn" and
      dst = -1 and
      src = [0, 1]
      or
      name = "strstr" and
      dst = -1 and
      src = [0, 1]
      or
      name = "strtok" and
      dst = 0 and
      src = 1
    )
  }

  /**
   * An expansion of `libraryFunctionNameParamTableSimpleString` to include internal functions with
   * prefixes/suffixes such as "__builtin_%"" or "%_chk" (e.g. `__builtin___strcpy_chk`)
   */
  bindingset[name]
  Function libraryFunctionNameParamTableSimpleStringRegex(string name, int dst, int src, int src_sz, int dst_sz) {
    exists(string stdName |
      result = libraryFunctionNameParamTableSimpleString(stdName, dst,  src,  src_sz, dst_sz) and
      (
        name = stdName
        or
        getNameOrInternalName(name) = stdName
      )
    )
  }

  /**
   * A relation of the indices of buffer and size parameters of standard library functions
   * which are defined in rules CERT ARR38-C and MISRA-C rules 21.17 and 21.18.
   */
  private Function libraryFunctionNameParamTable(
    string name, int dst, int src, int src_sz, int dst_sz
  ) {
    result = libraryFunctionNameParamTableSimpleString(name, dst, src, src_sz, dst_sz)
    or
    result.hasGlobalOrStdName(name) and
    (
      name = ["fgets", "fgetws"] and
      dst = 0 and
      src = -1 and
      src_sz = -1 and
      dst_sz = 1
      or
      name = ["mbstowcs", "wcstombs"] and
      dst = 0 and
      src = 1 and
      src_sz = -1 and
      dst_sz = 2
      or
      name = ["mbrtoc16", "mbrtoc32"] and
      dst = 0 and
      src = 1 and
      src_sz = 2 and
      dst_sz = -1
      or
      name = ["mbsrtowcs", "wcsrtombs"] and
      dst = 0 and
      src = 1 and
      src_sz = -1 and
      dst_sz = 2
      or
      name = ["mbtowc", "mbrtowc"] and
      dst = 0 and
      src = 1 and
      src_sz = 2 and
      dst_sz = -1
      or
      name = ["mblen", "mbrlen"] and
      dst = -1 and
      src = 0 and
      src_sz = 1 and
      dst_sz = -1
      or
      name = ["memchr", "wmemchr"] and
      dst = -1 and
      src = 0 and
      src_sz = 2 and
      dst_sz = -1
      or
      name = ["memset", "wmemset"] and
      dst = 0 and
      src = -1 and
      src_sz = -1 and
      dst_sz = 2
      or
      name = ["strftime", "wcsftime"] and
      dst = 0 and
      src = -1 and
      src_sz = -1 and
      dst_sz = 1
      or
      name = ["strxfrm", "wcsxfrm"] and
      dst = 0 and
      src = 1 and
      src_sz = -1 and
      dst_sz = 2
      or
      name = ["strncat", "wcsncat"] and
      dst = 0 and
      src = 1 and
      src_sz = 2 and
      dst_sz = -1
      or
      name = "wcsncat" and
      dst = 0 and
      src = 1 and
      src_sz = 2 and
      dst_sz = -1
      or
      name = ["snprintf", "vsnprintf", "swprintf", "vswprintf"] and
      dst = 0 and
      src = -1 and
      src_sz = -1 and
      dst_sz = 1
      or
      name = "setvbuf" and
      dst = -1 and
      src = 1 and
      src_sz = 3 and
      dst_sz = -1
      or
      name =
        [
          "memcpy", "wmemcpy", "memmove", "wmemmove", "strncpy", "wcsncpy", "memcmp", "wmemcmp",
          "strncmp", "wcsncmp"
        ] and
      dst = 0 and
      src = 1 and
      src_sz = 2 and
      dst_sz = 2
      or
      name = ["bsearch", "qsort"] and
      dst = 1 and
      src = -1 and
      src_sz = -1 and
      dst_sz = -1
      or
      name = ["fread", "fwrite"] and
      dst = 0 and
      src = -1 and
      src_sz = -1 and
      dst_sz = -1
    )
  }

  /**
   * An expansion of `libraryFunctionNameParamTable` to include internal functions with
   * prefixes/suffixes such as "__builtin_%"" or "%_chk" (e.g. `__builtin___strncpy_chk`)
   */
  bindingset[name]
  Function libraryFunctionNameParamTableRegex(string name, int dst, int src, int src_sz, int dst_sz) {
    exists(string stdName |
      result = libraryFunctionNameParamTable(stdName, dst, src, src_sz, dst_sz) and
      (
        name = stdName
        or
        getNameOrInternalName
    (name) = stdName
      )
    )
  }

  /**
   * A library function that accesses one or more buffers supplied via arguments.
   */
  class BufferAccessLibraryFunction extends Function {
    BufferAccessLibraryFunction() {
      this = libraryFunctionNameParamTableRegex(this.getName(), _, _, _, _)
    }

    int getWriteParamIndex() {
      this = libraryFunctionNameParamTableRegex(this.getName(), result, _, _, _)
    }

    int getReadParamIndex() {
      this = libraryFunctionNameParamTableRegex(this.getName(), _, result, _, _)
    }

    int getReadSizeParamIndex() {
      this = libraryFunctionNameParamTableRegex(this.getName(), _, _, result, _)
    }

    int getWriteCountParamIndex() {
      this = libraryFunctionNameParamTableRegex(this.getName(), _, _, _, result)
    }

    Parameter getReadParam() { result = this.getParameter(this.getReadParamIndex()) }

    Parameter getWriteParam() { result = this.getParameter(this.getWriteParamIndex()) }

    Parameter getReadSizeParam() { result = this.getParameter(this.getReadSizeParamIndex()) }

    Parameter getWriteSizeParam() { result = this.getParameter(this.getWriteCountParamIndex()) }

    int getDestinationParameterElementSize() {
      this.getWriteParam().getType().(PointerType).getBaseType().getSize() = result
    }

    int getSourceParameterElementSize() {
      this.getReadParam().getType().(PointerType).getBaseType().getSize() = result
    }

    predicate getANullTerminatedParameterIndex(int i) {
      // by default, require null-terminated parameters for src but not dst
      this.getReadParam().getIndex() = i
    }

    predicate sizeArgExclusiveOfNullTerminator(int i) {
      // by default, require size parameters to be exclusive of null terminator
      i >= 0 and
      i <= this.getNumberOfParameters() and
      (
        this = libraryFunctionNameParamTableRegex(this.getName(), _, _, i, _)
      )
    }
  }

  /**
   * A library function that accesses one or more string buffers and has no
   * additional parameters for specifying the size of the buffers.
   */
  class SimpleStringLibraryFunction extends BufferAccessLibraryFunction {
    SimpleStringLibraryFunction() {
      this = libraryFunctionNameParamTableSimpleStringRegex(this.getName(), _, _, _, _)
    }
  }

  /**
   * A `BufferAccessLibraryFunction` that performs string concatenation.
   */
  abstract class StringConcatenationFunctionLibraryFunction extends BufferAccessLibraryFunction { }

  /**
   * A `BufferAccessLibraryFunction` modelling `strcat`
   */
  class StrcatLibraryFunction extends 
    StringConcatenationFunctionLibraryFunction, SimpleStringLibraryFunction {
    StrcatLibraryFunction() { this.getName() = getNameOrInternalName("strcat") }

    override predicate nullTerminatedParameter(int i) {
      // `strcat` requires null-terminated parameters for both src and dst
      i = [0, 1]
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `strncat` or `wcsncat`
   */
  class StrncatLibraryFunction extends StringConcatenationFunctionLibraryFunction {
    StrncatLibraryFunction() { this.getName() = getNameOrInternalName(["strncat", "wcsncat"]) }

    override predicate nullTerminatedParameter(int i) {
      // `strncat` requires null-terminated parameters for both src and dst
      i = [0, 1]
    }
  }

  /**
   * A `FunctionCall` to a `BufferAccessLibraryFunction` that provides predicates for
   * reasoning about buffer overflow and other buffer access violations.
   */
  abstract class BufferAccessLibraryFunctionCall extends FunctionCall {
    BufferAccessLibraryFunctionCall() { this.getTarget() instanceof BufferAccessLibraryFunction }

    Expr getReadArg() {
      result = this.getArgument(this.getTarget().(BufferAccessLibraryFunction).getReadParamIndex())
    }

    Expr getWriteArg() {
      result = this.getArgument(this.getTarget().(BufferAccessLibraryFunction).getWriteParamIndex())
    }

    Expr getReadSizeArg() {
      result =
        this.getArgument(this.getTarget().(BufferAccessLibraryFunction).getReadSizeParamIndex())
    }

    Expr getWriteSizeArg() {
      result =
        this.getArgument(this.getTarget().(BufferAccessLibraryFunction).getWriteCountParamIndex())
    }
  }

  /**
   * A `FunctionCall` to a `BufferAccessLibraryFunction` that contains only one or two string buffers
   * as its arguments but no specific size arguments, as size is deduced via null-termination.
   */
  class SimpleStringBufferAccessLibraryFunctionCall extends BufferAccessLibraryFunction {
    SimpleStringBufferAccessLibraryFunction
  }

  int getStatedAllocValue(Expr e) {
    // `upperBound(e)` defaults to `exprMaxVal(e)` when `e` isn't analyzable. So to get a meaningful
    // result in this case we pick the minimum value obtainable from dataflow and range analysis.
    if upperBound(e) = exprMaxVal(e) 
    then
      result = max(Expr source | DataFlow::localExprFlow(source, e) | source.getValue().toInt())
    else
    result = 
      upperBound(e)
        .minimum(min(Expr source | DataFlow::localExprFlow(source, e) | source.getValue().toInt()))

    
  }

  int getStatedValue(Expr e) {
    result =
      upperBound(e)
          .minimum(min(Expr source | DataFlow::localExprFlow(source, e) | source.getValue().toInt()))
  }

  /**
   * A class for reasoning about the offset of a variable from the original value flowing to it
   * as a result of arithmetic or pointer arithmetic expressions.
   */
  int getArithmeticOperandStatedValue(Expr expr) {
    result = getStatedValue(expr.(PointerArithmeticExpr).getOperand())
    or
    // &(array[index]) expressions
    result = getStatedValue(expr.(AddressOfExpr).getOperand().(PointerArithmeticExpr).getOperand())
    or
    result = getStatedValue(expr.(BinaryArithmeticOperation).getRightOperand())
    or
    expr instanceof IncrementOperation and result = 1
    or
    expr instanceof DecrementOperation and result = -1
    or
    // fall-back if `expr` is not an arithmetic or pointer arithmetic expression
    not expr instanceof PointerArithmeticExpr and
    not expr.(AddressOfExpr).getOperand() instanceof PointerArithmeticExpr and
    not expr instanceof BinaryArithmeticOperation and
    not expr instanceof IncrementOperation and
    not expr instanceof DecrementOperation and
    result = 0
  }

  int constOrZero(Expr e) {
    result = e.getValue().toInt()
    or
    not exists(e.getValue().toInt()) and result = 0
  }

  abstract class PointerToObjectSource extends Expr {
    abstract Expr getPointer();

    abstract Expr getSizeExpr();

    abstract int getFixedSize();
  }

  class DynamicAllocationSource extends PointerToObjectSource 
    instanceof AllocationExpr, FunctionCall {
    DynamicAllocationSource() {
      // exclude OperatorNewAllocationFunction to only deal with raw malloc-style calls,
      // which do not apply a multiple to the size of the allocation passed to them.
      not this.(FunctionCall).getTarget() instanceof OperatorNewAllocationFunction
    }

    override Expr getPointer() { result = this }

    override Expr getSizeExpr() {
      // AllocationExpr may sometimes return a subexpression of the size expression
      // in order to separate the size from a sizeof expression in a MulExpr.
      exists(AllocationFunction f |
        f = this.(FunctionCall).getTarget() and
        result = this.(FunctionCall).getArgument(f.getSizeArg())
      )
    }

    /**
     * Returns either `getSizeExpr()`, or, if a value assigned to a variable flows
     * to `getSizeExpr()` or an `AddExpr` within it, the value assigned to that variable.
     *
     * If an `AddExpr` exists in the value assignment or `getSizeExpr()`, and that `AddExpr`
     * has a constant right operand, then value of that operand is `offset`. Otherwise, `offset` is 0.
     *
     * If no `AddExpr` exists, `base = result`. Otherwise, `base` is the left operand of the `AddExpr`.
     * If the left operand of the `AddExpr` comes from a variable assignment, `base` is assigned value.
     *
     * This predicate serves as a rough heuristic for cases such as the following:
     * 1. `size_t sz = strlen(src) + 1; malloc(sz);`
     * 2. `size_t sz = strlen(src); malloc(sz + 1);`
     */
    Expr getSizeExprSource(Expr base, int offset) {
      if
        exists(Variable v, AddExpr ae |
          // case 1: variable_access + const in the size expression
          this.getSizeExpr() = ae and
          result = v.getAnAssignedValue() and
          base = ae.getLeftOperand() and
          offset = constOrZero(ae.getRightOperand()) and
          DataFlow::localExprFlow(result, base)
          or
          // case 2: expr + const in the variable assignment
          v.getAnAssignedValue() = ae and
          result = ae and
          base = ae.getLeftOperand() and
          offset = constOrZero(ae.getRightOperand()) and
          DataFlow::localExprFlow(result, this.getSizeExpr())
        )
      then any() // all logic handled in the `if` clause
      else (
        offset = 0 and
        // case 3: a variable is read in the size expression
        // if the VariableAccess does not have a computable constant value,
        // the source node could still be useful for data-flow and GVN comparisons
        if this.getSizeExpr() instanceof VariableAccess
        then
          exists(Variable v |
            v = this.getSizeExpr().(VariableAccess).getTarget() and
            not v instanceof Field and
            DataFlow::localExprFlow(v.getAnAssignedValue(), base) and
            result = base
          )
        else (
          // Case 4: no variable access in the size expression
          // This case is equivalent to getSizeExpr.
          base = this.getSizeExpr() and
          result = base
        )
      )
    }

    override int getFixedSize() { result = getStatedAllocValue(getSizeExpr()) }
  }

  class AddressOfExprSource extends PointerToObjectSource, AddressOfExpr {
    AddressOfExprSource() {
      exists(Variable v |
        v = this.getOperand().(VariableAccess).getTarget() and
        not v.getUnderlyingType() instanceof PointerType and
        not v instanceof Field
      )
    }

    override Expr getPointer() { result = this }

    override Expr getSizeExpr() { none() }

    override int getFixedSize() { result = min(this.getOperand().getType().getSize()) }
  }

  class StaticBufferAccessSource extends PointerToObjectSource instanceof VariableAccess {
    StaticBufferAccessSource() {
      not this.getTarget() instanceof Field and
      this.getTarget().getUnderlyingType().(ArrayType).getSize() > 0
    }

    override Expr getPointer() { result = this }

    override Expr getSizeExpr() { none() }

    override int getFixedSize() {
      result = this.(VariableAccess).getTarget().getUnderlyingType().(ArrayType).getSize()
    }
  }

  class PointerToObjectSourceOrSizeToBufferAccessFunctionConfig extends DataFlow::Configuration {
    PointerToObjectSourceOrSizeToBufferAccessFunctionConfig() {
      this = "PointerToObjectSourceOrSizeToBufferAccessFunctionConfig"
    }

    override predicate isSource(DataFlow::Node source) {
      source.asExpr() instanceof PointerToObjectSource
      or
      exists(PointerToObjectSource ptr |
        source.asExpr() = ptr.getSizeExpr() or
        source.asExpr() = ptr.(DynamicAllocationSource).getSizeExprSource(_, _)
      )
    }

    override predicate isSink(DataFlow::Node sink) {
      exists(BufferAccessLibraryFunctionCall call, Expr arg | 
        arg = call.getAnArgument()
        and
        (
          sink.asExpr() = arg
          or
          getArithmeticOffsetValue(arg) > 0 and
          sink.asExpr() = arg.getAChild*()
        )
      )
    }
  }

  predicate hasFlowFromBufferOrSizeExprToUse(Expr source, Expr use) {
    exists(PointerToObjectSourceOrSizeToBufferAccessFunctionConfig config, Expr useOrChild |
      (
        useOrChild = use
        or
        getArithmeticOffsetValue(use) > 0 and
        useOrChild = use.getAChild*() 
      )
      and
      config.hasFlow(DataFlow::exprNode(source), DataFlow::exprNode(useOrChild))
    )
  }

  predicate bufferUseComputableBufferSize(Expr bufferUse, Expr source, int size) {
    bufferUse = any(BufferAccessLibraryFunctionCall call).getAnArgument() and
    // flow from a PointerToObjectSource for which we can compute the exact size
    size = source.(PointerToObjectSource).getFixedSize() and
    hasFlowFromBufferOrSizeExprToUse(source, bufferUse)
  }

  predicate bufferUseNonComputableSize(Expr bufferUse, Expr source) {
    bufferUse = any(BufferAccessLibraryFunctionCall call).getAnArgument() and
    not bufferUseComputableBufferSize(bufferUse, source, _) and
    hasFlowFromBufferOrSizeExprToUse(source.(DynamicAllocationSource), bufferUse)
  }

  predicate sizeExprComputableSize(Expr sizeExpr, Expr source, int size) {
    sizeExpr = any(BufferAccessLibraryFunctionCall call).getAnArgument() and
    (
      // computable direct value
      size = getStatedValue(sizeExpr) and
      source = sizeExpr
      or
      // computable source value that flows to the size expression
      size = source.(DynamicAllocationSource).getFixedSize() and
      hasFlowFromBufferOrSizeExprToUse(source.(DynamicAllocationSource).getSizeExprSource(_, _), sizeExpr)
    )
  }

  /**
   * If the size is not computable locally, then it is either:
   *
   * 1. A dynamic allocation, from which we can get `getSizeExprSource()', from which
   *    we can either check specific logic (e.g. string length with offset) or compare GVNs.
   * 2. An unrelateable size expression, which we might, however, be able to compute the bounds
   *    of and check against the buffer size, if that is known.
   *
   * In case 2, this predicate does not hold.
   *
   * NOTE: This predicate does not actually perform the above mentioned heuristics.
   */
  predicate sizeExprNonComputableSize(
    Expr bufferSizeArg, Expr alloc, Expr allocSize, Expr allocSizeBase, int offset
  ) {
    bufferSizeArg = any(BufferAccessLibraryFunctionCall call).getAnArgument() and
    not sizeExprComputableSize(bufferSizeArg, alloc, _) and
    allocSize = alloc.(DynamicAllocationSource).getSizeExprSource(allocSizeBase, offset) and
    hasFlowFromBufferOrSizeExprToUse(allocSize, bufferSizeArg)
  }

  predicate isBufferSizeExprSameAsSourceSizeExpr(
    Expr bufferUse, Expr bufferSize, Expr sizeSource, PointerToObjectSource sourceBufferAllocation,
    int s1, int s2, BufferAccessLibraryFunctionCall fc
  ) {
    //bufferUse.getUnderlyingType() instanceof PointerOrArrayType and
    //not bufferSize.getUnderlyingType() instanceof PointerOrArrayType and
    fc.getAnArgument() = bufferUse and
    fc.getAnArgument() = bufferSize and
    not bufferUse = bufferSize and
    (
      bufferUseComputableBufferSize(bufferUse, sourceBufferAllocation, s1) and
      sizeExprComputableSize(bufferSize, sizeSource, s2) and
      s1 = s2
      or
      s1 = -1 and
      s2 = -1 and
      sizeSource = sourceBufferAllocation and
      bufferUseNonComputableSize(bufferUse, sizeSource) and
      sizeExprNonComputableSize(bufferSize, sourceBufferAllocation, _, _, _)
      or
      s1 = -2 and
      s2 = -2 and
      sizeSource = sourceBufferAllocation.(DynamicAllocationSource).getSizeExprSource(_, _) and
      bufferUseNonComputableSize(bufferUse, sourceBufferAllocation) and
      globalValueNumber(sizeSource) = globalValueNumber(bufferSize)
    )
  }

  int getArithmeticOffsetValue(Expr expr) {
    result = getStatedValue(expr.(PointerArithmeticExpr).getOperand())
    or
    // edge-case: &(array[index]) expressions
    result = getStatedValue(expr.(AddressOfExpr).getOperand().(PointerArithmeticExpr).getOperand())
    or
    // AddExpr
    result = getStatedValue(expr.(AddExpr).getAnOperand())
    or
    // SubExpr
    result = -getStatedValue(expr.(SubExpr).getAnOperand())
    or
    // fall-back
    not expr instanceof PointerArithmeticExpr and
    not expr.(AddressOfExpr).getOperand() instanceof PointerArithmeticExpr and
    result = 0
  }

  predicate isBufferSizeExprGreaterThanSourceSizeExpr (
    Expr bufferUse, Expr bufferSize, Expr sizeSource, PointerToObjectSource sourceBufferAllocation,
    int s1, int s2, BufferAccessLibraryFunctionCall fc
  ) {
    //bufferUse.getUnderlyingType() instanceof PointerOrArrayType and
    //not bufferSize.getUnderlyingType() instanceof PointerOrArrayType and
    fc.getAnArgument() = bufferUse and
    fc.getAnArgument() = bufferSize and
    not bufferUse = bufferSize and
    (
      bufferUseComputableBufferSize(bufferUse, sourceBufferAllocation, s1) and
      sizeExprComputableSize(bufferSize, sizeSource, s2) and
      ( 
        s1 - getArithmeticOffsetValue(bufferUse) < s2 + getArithmeticOffsetValue(bufferSize) 
        or 
        s2 = 0
      )
      or
      s1 = -1 and
      s2 = -1 and
      sizeSource = sourceBufferAllocation and
      bufferUseNonComputableSize(bufferUse, sizeSource) and
      sizeExprNonComputableSize(bufferSize, sourceBufferAllocation, _, _, _)
      or
        exists(int offset, Expr base |
          sizeSource = sourceBufferAllocation.(DynamicAllocationSource).getSizeExprSource(base, offset) and
          bufferUseNonComputableSize(bufferUse, sourceBufferAllocation) and
          not globalValueNumber(sizeSource) = globalValueNumber(bufferSize) and
          globalValueNumber(base) = globalValueNumber(bufferSize.getAChild*()) and
          s1 = getArithmeticOffsetValue(bufferUse) and 
          s2 = getArithmeticOffsetValue(bufferSize) and
          s1 >= s2 - offset
        )
    )
  }
}
