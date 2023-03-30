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
import semmle.code.cpp.security.BufferWrite
import semmle.code.cpp.rangeanalysis.SimpleRangeAnalysis

module OOB {
  bindingset[name, result]
  private string getNameOrInternalName(string name) {
    result = name or
    result.regexpMatch("__.*_+" + name + "_.*")
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
   * The `SimpleStringLibraryFunction` base class provides an appropriate
   * interface for analyzing the functions in the below table.
   */
  private Function libraryFunctionNameParamTableSimpleString(
    string name, int dst, int src, int src_sz, int dst_sz
  ) {
    result.getName() = getNameOrInternalName(name) and
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
      name = ["strcmp", "strcoll"] and
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
   * A relation of the indices of buffer and size parameters of standard library functions
   * which are defined in rules CERT ARR38-C and MISRA-C rules 21.17 and 21.18.
   */
  private Function libraryFunctionNameParamTable(
    string name, int dst, int src, int src_sz, int dst_sz
  ) {
    result = libraryFunctionNameParamTableSimpleString(name, dst, src, src_sz, dst_sz)
    or
    result.getName() = getNameOrInternalName(name) and
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
   * A library function that accesses one or more buffers supplied via arguments.
   */
  class BufferAccessLibraryFunction extends Function {
    BufferAccessLibraryFunction() { this = libraryFunctionNameParamTable(_, _, _, _, _) }

    /**
     * Returns the indices of parameters that are a destination buffer.
     */
    int getWriteParamIndex() {
      this = libraryFunctionNameParamTable(_, result, _, _, _) and
      result >= 0
    }

    /**
     * Returns the indices of parameters that are a source buffer.
     */
    int getReadParamIndex() {
      this = libraryFunctionNameParamTable(_, _, result, _, _) and
      result >= 0
    }

    /**
     * Returns the index of the parameter that is the source buffer size.
     */
    int getReadSizeParamIndex() {
      this = libraryFunctionNameParamTable(_, _, _, result, _) and
      result >= 0
    }

    /**
     * Returns the index of the parameter that is the destination buffer size.
     */
    int getWriteCountParamIndex() {
      this = libraryFunctionNameParamTable(_, _, _, _, result) and
      result >= 0
    }

    /**
     * Gets a parameter than is a source (read) buffer.
     */
    Parameter getReadParam() { result = this.getParameter(this.getReadParamIndex()) }

    /**
     * Gets a parameter than is a destination (write) buffer.
     */
    Parameter getWriteParam() { result = this.getParameter(this.getWriteParamIndex()) }

    /**
     * Gets a parameter than is a source (read) buffer size.
     */
    Parameter getReadSizeParam() { result = this.getParameter(this.getReadSizeParamIndex()) }

    /**
     * Gets a parameter than is a destination (write) buffer size.
     */
    Parameter getWriteSizeParam() { result = this.getParameter(this.getWriteCountParamIndex()) }

    /**
     * Gets the size of an element in the destination buffer class
     */
    int getWriteParamElementSize(Parameter p) {
      p = this.getWriteParam() and
      p.getType().stripType().getSize().maximum(1) = result
    }

    /**
     * Gets the size of an element in the source buffer class
     */
    int getReadParamElementSize(Parameter p) {
      p = this.getReadParam() and
      p.getType().stripType().getSize().maximum(1) = result
    }

    predicate getANullTerminatedParameterIndex(int i) {
      // by default, require null-terminated parameters for src but
      // only if the type of src is a plain char pointer or wchar_t
      this.getReadParamIndex() = i and
      exists(Type baseType |
        baseType = this.getReadParam().getType().(DerivedType).getBaseType*() and
        (
          baseType instanceof CharType or
          baseType instanceof Wchar_t
        )
      )
    }

    predicate getALengthParameterIndex(int i) {
      // by default, size parameters do not exclude the size of a null terminator
      none()
    }

    /**
     * Holds if the read or write parameter at index `i` is allowed to be null.
     */
    predicate getAPermissiblyNullParameterIndex(int i) {
      // by default, pointer parameters are not allowed to be null
      none()
    }
  }

  /**
   * A library function that accesses one or more string buffers and has no
   * additional parameters for specifying the size of the buffers.
   */
  class SimpleStringLibraryFunction extends BufferAccessLibraryFunction {
    SimpleStringLibraryFunction() {
      this = libraryFunctionNameParamTableSimpleString(this.getName(), _, _, -1, -1)
    }

    override predicate getANullTerminatedParameterIndex(int i) {
      // by default, require null-terminated parameters for src but
      // only if the type of src is a plain char pointer.
      this.getReadParamIndex() = i and
      this.getReadParam()
          .getType()
          .getUnspecifiedType()
          .(PointerType)
          .getBaseType()
          .getUnspecifiedType() instanceof PlainCharType
    }
  }

  /**
   * A `BufferAccessLibraryFunction` that performs string concatenation.
   */
  abstract class StringConcatenationFunctionLibraryFunction extends BufferAccessLibraryFunction { }

  /**
   * A `BufferAccessLibraryFunction` modelling `strcat`
   */
  class StrcatLibraryFunction extends StringConcatenationFunctionLibraryFunction,
    SimpleStringLibraryFunction {
    StrcatLibraryFunction() { this.getName() = getNameOrInternalName("strcat") }

    override predicate getANullTerminatedParameterIndex(int i) {
      // `strcat` requires null-terminated parameters for both src and dst
      i = [0, 1]
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `strncat` or `wcsncat`
   */
  class StrncatLibraryFunction extends StringConcatenationFunctionLibraryFunction {
    StrncatLibraryFunction() { this.getName() = getNameOrInternalName(["strncat", "wcsncat"]) }

    override predicate getANullTerminatedParameterIndex(int i) {
      // `strncat` requires null-terminated parameters for both src and dst
      i = [0, 1]
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `strncpy`
   */
  class StrncpyLibraryFunction extends BufferAccessLibraryFunction {
    StrncpyLibraryFunction() { this.getName() = getNameOrInternalName("strncpy") }

    override predicate getANullTerminatedParameterIndex(int i) {
      // `strncpy` does not require null-terminated parameters
      none()
    }
  }

  /**
   * An construction of a pointer to a buffer.
   */
  abstract class BufferAccess extends Expr {
    abstract predicate hasABuffer(Expr buffer, Expr size, int sizeMult);

    Expr getARelevantExpr() {
      hasABuffer(result, _, _)
      or
      hasABuffer(_, result, _)
    }
  }

  class PointerArithmeticBufferAccess extends BufferAccess instanceof PointerArithmeticExpr {
    override predicate hasABuffer(Expr buffer, Expr size, int sizeMult) {
      buffer = this.(PointerArithmeticExpr).getPointer() and
      size = this.(PointerArithmeticExpr).getOperand() and
      sizeMult =
        buffer.getType().getUnspecifiedType().(DerivedType).getBaseType().getSize().maximum(1)
    }
  }

  class ArrayBufferAccess extends BufferAccess, ArrayExpr {
    override predicate hasABuffer(Expr buffer, Expr size, int sizeMult) {
      buffer = this.getArrayBase() and
      size = this.getArrayOffset() and
      sizeMult =
        buffer.getType().getUnspecifiedType().(DerivedType).getBaseType().getSize().maximum(1)
    }
  }

  /**
   * A `FunctionCall` to a `BufferAccessLibraryFunction` that provides predicates for
   * reasoning about buffer overflow and other buffer access violations.
   */
  class BufferAccessLibraryFunctionCall extends FunctionCall, BufferAccess {
    BufferAccessLibraryFunctionCall() { this.getTarget() instanceof BufferAccessLibraryFunction }

    override predicate hasABuffer(Expr buffer, Expr size, int sizeMult) {
      buffer = this.getWriteArg() and
      size = this.getWriteSizeArg() and
      sizeMult = this.getWriteSizeArgMult()
      or
      buffer = this.getReadArg() and
      size = this.getReadSizeArg() and
      sizeMult = this.getReadSizeArgMult()
    }

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

    int getReadSizeArgMult() {
      result = this.getTarget().(BufferAccessLibraryFunction).getReadParamElementSize(_)
    }

    int getWriteSizeArgMult() {
      result = this.getTarget().(BufferAccessLibraryFunction).getWriteParamElementSize(_)
    }
  }

  class SimpleStringLibraryFunctionCall extends BufferAccessLibraryFunctionCall {
    SimpleStringLibraryFunctionCall() { this.getTarget() instanceof SimpleStringLibraryFunction }
  }

  /**
   * Holds only if `e` is a constant, or flows from a constant.
   */
  int getStatedAllocValue(Expr e) {
    if upperBound(e) = exprMaxVal(e)
    then result = max(Expr source | DataFlow::localExprFlow(source, e) | source.getValue().toInt())
    else
      result =
        upperBound(e)
            .minimum(min(Expr source |
                DataFlow::localExprFlow(source, e)
              |
                source.getValue().toInt()
              ))
  }

  /**
   * Holds only if `e` is a constant, or flows from a constant.
   */
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

    abstract predicate isNotNullTerminated();
  }

  class DynamicAllocationSource extends PointerToObjectSource instanceof AllocationExpr,
    FunctionCall {
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
      if this.getSizeExpr() instanceof AddExpr
      then
        exists(AddExpr ae |
          exists(Variable v |
            // case 1: variable access + const in the size expression
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
          or
          // case 3: function call + const
          result = ae and
          this.getSizeExpr() = ae and
          ae.getLeftOperand() = base and
          ae.getLeftOperand() instanceof FunctionCall and
          offset = constOrZero(ae.getRightOperand())
        )
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

    override predicate isNotNullTerminated() { none() }
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

    override predicate isNotNullTerminated() { none() }
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

    override predicate isNotNullTerminated() {
      exists(CharArrayInitializedWithStringLiteral cl |
        cl = this.(VariableAccess).getTarget().getInitializer().getExpr() and
        cl.getContainerLength() <= cl.getStringLiteralLength()
      )
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
      exists(BufferAccess bufferAccess, Expr arg |
        arg = bufferAccess.getARelevantExpr() and
        (
          sink.asExpr() = arg
          or
          getArithmeticOffsetValue(arg) > 0 and
          sink.asExpr() = arg.getAChild*()
        )
      )
    }

    override predicate isBarrierOut(DataFlow::Node node) {
      // the default interprocedural data-flow model flows through any array assignment expressions
      // to the qualifier (array base or pointer dereferenced) instead of the individual element
      // that the assignment modifies. this default behaviour causes false positives for any future
      // access of the array base, so remove the assignment edge at the expense of false-negatives.
      exists(AssignExpr a |
        node.asExpr() = a.getRValue().getAChild*() and
        (
          a.getLValue() instanceof ArrayExpr or
          a.getLValue() instanceof PointerDereferenceExpr
        )
      )
      or
      // remove flow from `src` to `dst` in memcpy
      exists(FunctionCall fc |
        fc.getTarget().getName() = getNameOrInternalName("memcpy") and
        node.asExpr() = fc.getArgument(1).getAChild*()
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
      ) and
      config.hasFlow(DataFlow::exprNode(source), DataFlow::exprNode(useOrChild))
    )
  }

  predicate bufferUseComputableBufferSize(Expr bufferUse, Expr source, int size) {
    // flow from a PointerToObjectSource for which we can compute the exact size
    size = source.(PointerToObjectSource).getFixedSize() and
    hasFlowFromBufferOrSizeExprToUse(source, bufferUse)
  }

  predicate bufferUseNonComputableSize(Expr bufferUse, Expr source) {
    not bufferUseComputableBufferSize(bufferUse, source, _) and
    hasFlowFromBufferOrSizeExprToUse(source.(DynamicAllocationSource), bufferUse)
  }

  predicate sizeExprComputableSize(Expr sizeExpr, Expr source, int size) {
    // computable direct value
    size = getStatedValue(sizeExpr) and
    source = sizeExpr
    or
    // computable source value that flows to the size expression
    size = source.(DynamicAllocationSource).getFixedSize() and
    hasFlowFromBufferOrSizeExprToUse(source.(DynamicAllocationSource).getSizeExprSource(_, _),
      sizeExpr)
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
    bufferSizeArg = any(BufferAccess access).getARelevantExpr() and
    not sizeExprComputableSize(bufferSizeArg, alloc, _) and
    allocSize = alloc.(DynamicAllocationSource).getSizeExprSource(allocSizeBase, offset) and
    hasFlowFromBufferOrSizeExprToUse(allocSize, bufferSizeArg)
  }

  predicate isSizeArgGreaterThanBufferSize(
    Expr bufferArg, Expr sizeArg, PointerToObjectSource bufferSource, int bufferArgSize,
    int sizeArgValue, BufferAccess bufferAccess, int sizeMult
  ) {
    bufferAccess.hasABuffer(bufferArg, sizeArg, sizeMult) and
    (
      bufferUseComputableBufferSize(bufferArg, bufferSource, bufferArgSize) and
      // If the bufferArg is an access of a static buffer, do not look for "long distant" sources
      (bufferArg instanceof StaticBufferAccessSource implies bufferSource = bufferArg) and
      sizeExprComputableSize(sizeArg, _, sizeArgValue) and
      bufferArgSize - getArithmeticOffsetValue(bufferArg) <
        sizeMult.(float) * (sizeArgValue + getArithmeticOffsetValue(sizeArg)).(float)
    )
  }

  predicate isSizeArgNotCheckedLessThanFixedBufferSize(
    Expr bufferArg, Expr sizeArg, PointerToObjectSource bufferSource, int bufferArgSize,
    BufferAccess bufferAccess, int sizeArgUpperBound, int sizeMult
  ) {
    bufferAccess.hasABuffer(bufferArg, sizeArg, sizeMult) and
    bufferUseComputableBufferSize(bufferArg, bufferSource, bufferArgSize) and
    // If the bufferArg is an access of a static buffer, do not look for "long distant" sources
    (bufferArg instanceof StaticBufferAccessSource implies bufferSource = bufferArg) and
    // Not a size expression for which we can compute a specific size
    not sizeExprComputableSize(sizeArg, _, _) and
    // Range analysis considers the upper bound to be larger than the buffer size
    sizeArgUpperBound = upperBound(sizeArg) and
    // Ignore bitwise & operations
    not sizeArg instanceof BitwiseAndExpr and
    sizeArgUpperBound * sizeMult > bufferArgSize and
    // There isn't a relational operation guarding this access that seems to check the
    // upper bound against a plausible terminal value
    not exists(RelationalOperation relOp, Expr checkedUpperBound |
      globalValueNumber(relOp.getLesserOperand()) = globalValueNumber(sizeArg) and
      checkedUpperBound = relOp.getGreaterOperand() and
      // There's no closer inferred bounds - otherwise we let range analysis check it
      upperBound(checkedUpperBound) = exprMaxVal(checkedUpperBound)
    )
  }

  predicate isSizeArgNotCheckedGreaterThanZero(
    Expr bufferArg, Expr sizeArg, PointerToObjectSource bufferSource, BufferAccess bufferAccess
  ) {
    exists(float sizeMult |
      bufferAccess.hasABuffer(bufferArg, sizeArg, sizeMult) and
      (
        bufferUseComputableBufferSize(bufferArg, bufferSource, _) or
        bufferUseNonComputableSize(bufferArg, bufferSource)
      ) and
      // Not a size expression for which we can compute a specific size
      not sizeExprComputableSize(sizeArg, _, _) and
      // If the lower bound is less than zero, taking into account any offsets
      lowerBound(sizeArg) + getArithmeticOffsetValue(bufferArg) < 0
    )
  }

  /**
   * Holds if the BufferAccess is accessed with a `base + accessOffset` on a buffer that was
   * allocated a size of the form `base + allocationOffset`.
   */
  predicate isBufferSizeOffsetOfGVN(
    BufferAccess bufferAccess, Expr bufferSize, Expr bufferUse, DynamicAllocationSource source,
    Expr sourceSizeExpr, Expr sourceSizeExprBase, int sourceSizeExprOffset, int sizeMult,
    int sizeArgOffset, int bufferArgOffset
  ) {
    bufferAccess.hasABuffer(bufferUse, bufferSize, sizeMult) and
    sourceSizeExpr = source.getSizeExprSource(sourceSizeExprBase, sourceSizeExprOffset) and
    bufferUseNonComputableSize(bufferUse, source) and
    not globalValueNumber(sourceSizeExpr) = globalValueNumber(bufferSize) and
    sizeArgOffset = getArithmeticOffsetValue(bufferSize.getAChild*()) and
    bufferArgOffset = getArithmeticOffsetValue(bufferUse) and
    sourceSizeExprOffset + bufferArgOffset < sizeArgOffset
  }

  predicate isMandatoryBufferArgNull(Expr bufferArg, BufferAccessLibraryFunctionCall fc) {
    exists(int i |
      i =
        [
          fc.getTarget().(BufferAccessLibraryFunction).getReadParamIndex(),
          fc.getTarget().(BufferAccessLibraryFunction).getWriteParamIndex()
        ] and
      not fc.getTarget().(BufferAccessLibraryFunction).getAPermissiblyNullParameterIndex(i) and
      bufferArg = fc.getArgument(i) and
      getStatedValue(bufferArg) = 0
    )
  }

  predicate isNullTerminatorMissingFromBufferArg(
    Expr bufferArg, PointerToObjectSource source, BufferAccessLibraryFunctionCall fc
  ) {
    exists(int i |
      fc.getTarget().(BufferAccessLibraryFunction).getANullTerminatedParameterIndex(i) and
      fc.getArgument(i) = bufferArg and
      source.isNotNullTerminated() and
      hasFlowFromBufferOrSizeExprToUse(source, bufferArg.getAChild*())
    )
  }

  predicate isReadBufferSizeSmallerThanWriteBufferSize(
    Expr readBuffer, Expr writeBuffer, SimpleStringLibraryFunctionCall fc
  ) {
    readBuffer = fc.getReadArg() and
    writeBuffer = fc.getWriteArg() and
    exists(int readBufferSize, int writeBufferSize |
      bufferUseComputableBufferSize(readBuffer, _, readBufferSize) and
      bufferUseComputableBufferSize(writeBuffer, _, writeBufferSize) and
      readBufferSize - getArithmeticOffsetValue(readBuffer) <
        writeBufferSize - getArithmeticOffsetValue(writeBuffer)
    )
  }
}
