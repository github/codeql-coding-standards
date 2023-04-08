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

module OOB {
  /**
   * Holds if `result` is either `name` or a string matching a pattern such as
   * `__builtin_*name*_chk` or similar. This predicate exists to model internal functions
   * such as `__builtin___memcpy_chk` under a common `memcpy` name in the table.
   */
  bindingset[name, result]
  string getNameOrInternalName(string name) {
    result.regexpMatch("^(?:__.*_+)?" + name + "(?:_[^s].*)?$")
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
      // do not specify a src and dst to avoid buffer size assumptions
      name = ["strtok", "strtok_r"] and
      dst = -1 and
      src = [0, 1]
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
      name = ["memcpy", "wmemcpy", "memmove", "wmemmove", "memcmp", "wmemcmp", "strncmp", "wcsncmp"] and
      dst = 0 and
      src = 1 and
      src_sz = 2 and
      dst_sz = 2
      or
      name = ["strncpy", "wcsncpy"] and
      dst = 0 and
      src = 1 and
      src_sz = -1 and
      dst_sz = 2
      or
      name = "qsort" and
      dst = 0 and
      src = -1 and
      src_sz = -1 and
      dst_sz = 1
      or
      name = "bsearch" and
      dst = -1 and
      src = 1 and
      src_sz = -1 and
      dst_sz = 2
      or
      name = "fread" and
      dst = 0 and
      src = -1 and
      src_sz = -1 and
      dst_sz = 2
      or
      name = "fwrite" and
      dst = -1 and
      src = 0 and
      src_sz = 2 and
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
    int getWriteSizeParamIndex() {
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
    Parameter getWriteSizeParam() { result = this.getParameter(this.getWriteSizeParamIndex()) }

    /**
     * Gets the size of an element in the destination buffer class
     */
    int getWriteParamElementSize(Parameter p) {
      p = this.getWriteParam() and
      p.getType().getUnspecifiedType().(DerivedType).getBaseType().getSize().maximum(1) = result
    }

    /**
     * Gets the size of an element in the source buffer class
     */
    int getReadParamElementSize(Parameter p) {
      p = this.getReadParam() and
      p.getType().getUnspecifiedType().(DerivedType).getBaseType().getSize().maximum(1) = result
    }

    /**
     * Holds if `i` is the index of a parameter of this function that requires arguments to be null-terminated.
     * This predicate should be overriden by extending classes to specify null-terminated parameters, if necessary.
     */
    predicate getANullTerminatedParameterIndex(int i) {
      // by default, require null-terminated parameters for src but
      // only if the type of src is a plain char pointer or wchar_t.
      this.getReadParamIndex() = i and
      exists(Type baseType |
        baseType = this.getReadParam().getUnspecifiedType().(PointerType).getBaseType() and
        (
          baseType.getUnspecifiedType() instanceof PlainCharType or
          baseType.getUnspecifiedType() instanceof Wchar_t
        )
      )
    }

    /**
     * Holds if `i` is the index of a parameter of this function that is a size multiplier.
     * This predicate should be overriden by extending classes to specify size multiplier parameters, if necessary.
     */
    predicate getASizeMultParameterIndex(int i) {
      // by default, there is no size multiplier parameter
      // exceptions: fread, fwrite, bsearch, qsort
      none()
    }

    /**
     * Holds if `i` is the index of a parameter of this function that expects an element count rather than buffer size argument.
     * This predicate should be overriden by extending classes to specify length parameters, if necessary.
     */
    predicate getALengthParameterIndex(int i) {
      // by default, size parameters do not exclude the size of a null terminator
      none()
    }

    /**
     * Holds if the read or write parameter at index `i` is allowed to be null.
     * This predicate should be overriden by extending classes to specify permissibly null parameters, if necessary.
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
      this = libraryFunctionNameParamTableSimpleString(_, _, _, -1, -1)
    }

    override predicate getANullTerminatedParameterIndex(int i) {
      // by default, require null-terminated parameters for src but
      // only if the type of src is a plain char pointer.
      this.getReadParamIndex() = i and
      this.getReadParam().getUnspecifiedType().(PointerType).getBaseType().getUnspecifiedType()
        instanceof PlainCharType
    }
  }

  /**
   * A `BufferAccessLibraryFunction` that performs string concatenation.
   */
  abstract class StringConcatenationFunctionLibraryFunction extends BufferAccessLibraryFunction {
    override predicate getANullTerminatedParameterIndex(int i) {
      // `strcat` and variants require null-terminated params for both src and dst
      i = [0, 1]
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `strcat`
   */
  class StrcatLibraryFunction extends StringConcatenationFunctionLibraryFunction {
    StrcatLibraryFunction() { this.getName() = getNameOrInternalName("strcat") }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `strncat` or `wcsncat`
   */
  class StrncatLibraryFunction extends StringConcatenationFunctionLibraryFunction {
    StrncatLibraryFunction() { this.getName() = getNameOrInternalName(["strncat", "wcsncat"]) }

    override predicate getALengthParameterIndex(int i) {
      // `strncat` and `wcsncat` exclude the size of a null terminator
      i = 2
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `strncpy`
   */
  class StrncpyLibraryFunction extends StringConcatenationFunctionLibraryFunction {
    StrncpyLibraryFunction() { this.getName() = getNameOrInternalName("strncpy") }

    override predicate getANullTerminatedParameterIndex(int i) {
      // `strncpy` does not require null-terminated parameters
      none()
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `strncmp`
   */
  class StrncmpLibraryFunction extends BufferAccessLibraryFunction {
    StrncmpLibraryFunction() { this.getName() = getNameOrInternalName("strncmp") }

    override predicate getANullTerminatedParameterIndex(int i) {
      // `strncmp` does not require null-terminated parameters
      none()
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `mbtowc` and `mbrtowc`
   */
  class MbtowcLibraryFunction extends BufferAccessLibraryFunction {
    MbtowcLibraryFunction() { this.getName() = getNameOrInternalName(["mbtowc", "mbrtowc"]) }

    override predicate getAPermissiblyNullParameterIndex(int i) {
      // `mbtowc` requires null-terminated parameters for both src and dst
      i = [0, 1]
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `mblen` and `mbrlen`
   */
  class MblenLibraryFunction extends BufferAccessLibraryFunction {
    MblenLibraryFunction() { this.getName() = getNameOrInternalName(["mblen", "mbrlen"]) }

    override predicate getAPermissiblyNullParameterIndex(int i) { i = 0 }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `setvbuf`
   */
  class SetvbufLibraryFunction extends BufferAccessLibraryFunction {
    SetvbufLibraryFunction() { this.getName() = getNameOrInternalName("setvbuf") }

    override predicate getAPermissiblyNullParameterIndex(int i) { i = 1 }

    override predicate getANullTerminatedParameterIndex(int i) {
      // `setvbuf` does not require a null-terminated buffer
      none()
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `snprintf`, `vsnprintf`, `swprintf`, and `vswprintf`.
   * This class overrides the `getANullTerminatedParameterIndex` predicate to include the `format` parameter.
   */
  class PrintfLibraryFunction extends BufferAccessLibraryFunction {
    PrintfLibraryFunction() {
      this.getName() = getNameOrInternalName(["snprintf", "vsnprintf", "swprintf", "vswprintf"])
    }

    override predicate getANullTerminatedParameterIndex(int i) {
      // `snprintf` and variants require a null-terminated format string
      i = 2
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `fread` and `fwrite`.
   */
  class FreadFwriteLibraryFunction extends BufferAccessLibraryFunction {
    FreadFwriteLibraryFunction() { this.getName() = getNameOrInternalName(["fread", "fwrite"]) }

    override predicate getASizeMultParameterIndex(int i) {
      // `fread` and `fwrite` have a size multiplier parameter
      i = 1
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `bsearch`
   */
  class BsearchLibraryFunction extends BufferAccessLibraryFunction {
    BsearchLibraryFunction() { this.getName() = getNameOrInternalName("bsearch") }

    override predicate getASizeMultParameterIndex(int i) {
      // `bsearch` has a size multiplier parameter
      i = 3
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `qsort`
   */
  class QsortLibraryFunction extends BufferAccessLibraryFunction {
    QsortLibraryFunction() { this.getName() = getNameOrInternalName("qsort") }

    override predicate getASizeMultParameterIndex(int i) {
      // `qsort` has a size multiplier parameter
      i = 2
    }
  }

  /**
   * A `BufferAccessLibraryFunction` modelling `strtok`
   */
  class StrtokLibraryFunction extends BufferAccessLibraryFunction {
    StrtokLibraryFunction() { this.getName() = getNameOrInternalName(["strtok", "strtok_r"]) }

    override predicate getAPermissiblyNullParameterIndex(int i) {
      // `strtok` does not require a non-null `str` parameter
      i = 0
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
      size = this.getWriteSizeArg(sizeMult)
      or
      buffer = this.getReadArg() and
      size = this.getReadSizeArg(sizeMult)
    }

    Expr getReadArg() {
      result = this.getArgument(this.getTarget().(BufferAccessLibraryFunction).getReadParamIndex())
    }

    Expr getWriteArg() {
      result = this.getArgument(this.getTarget().(BufferAccessLibraryFunction).getWriteParamIndex())
    }

    Expr getReadSizeArg(int mult) {
      result =
        this.getArgument(this.getTarget().(BufferAccessLibraryFunction).getReadSizeParamIndex()) and
      getReadSizeArgMult() = mult
    }

    Expr getWriteSizeArg(int mult) {
      result =
        this.getArgument(this.getTarget().(BufferAccessLibraryFunction).getWriteSizeParamIndex()) and
      getWriteSizeArgMult() = mult
    }

    int getReadSizeArgMult() {
      result =
        this.getTarget().(BufferAccessLibraryFunction).getReadParamElementSize(_) *
          getSizeMultArgValue()
    }

    int getWriteSizeArgMult() {
      result =
        this.getTarget().(BufferAccessLibraryFunction).getWriteParamElementSize(_) *
          getSizeMultArgValue()
    }

    int getSizeMultArgValue() {
      // Note: This predicate currently expects the size multiplier argument to be a constant.
      // This implementation could be improved with range-analysis or data-flow to determine the argument value.
      exists(int i |
        this.getTarget().(BufferAccessLibraryFunction).getASizeMultParameterIndex(i) and
        result = this.getArgument(i).getValue().toInt()
      )
      or
      not this.getTarget().(BufferAccessLibraryFunction).getASizeMultParameterIndex(_) and
      result = 1
    }
  }

  /**
   * A `FunctionCall` to a `SimpleStringLibraryFunction`
   */
  class SimpleStringLibraryFunctionCall extends BufferAccessLibraryFunctionCall {
    SimpleStringLibraryFunctionCall() { this.getTarget() instanceof SimpleStringLibraryFunction }
  }

  bindingset[dest]
  private Expr getSourceConstantExpr(Expr dest) {
    exists(result.getValue().toInt()) and
    DataFlow::localExprFlow(result, dest)
  }

  /**
   * Gets the smallest of the upper bound of `e` or the largest source value (i.e. "stated value") that flows to `e`.
   * Because range-analysis can over-widen bounds, take the minimum of range analysis and data-flow sources.
   *
   * If there is no source value that flows to `e`, this predicate does not hold.
   *
   * This predicate, if `e` is the size argument to malloc, would return `20` for the following example:
   * ```
   * size_t sz = condition ? 10 : 20;
   * malloc(sz);
   * ```
   */
  private int getMaxStatedValue(Expr e) {
    result = upperBound(e).minimum(max(getSourceConstantExpr(e).getValue().toInt()))
  }

  /**
   * Gets the smallest of the upper bound of `e` or the smallest source value (i.e. "stated value") that flows to `e`.
   * Because range-analysis can over-widen bounds, take the minimum of range analysis and data-flow sources.
   *
   * If there is no source value that flows to `e`, this predicate does not hold.
   *
   * This predicate, if `e` is the size argument to malloc, would return `10` for the following example:
   * ```
   * size_t sz = condition ? 10 : 20;
   * malloc(sz);
   * ```
   */
  bindingset[e]
  private int getMinStatedValue(Expr e) {
    result = upperBound(e).minimum(min(getSourceConstantExpr(e).getValue().toInt()))
  }

  /**
   * A class for reasoning about the offset of a variable from the original value flowing to it
   * as a result of arithmetic or pointer arithmetic expressions.
   */
  bindingset[expr]
  private int getArithmeticOffsetValue(Expr expr, Expr base) {
    result = getMinStatedValue(expr.(PointerArithmeticExpr).getOperand()) and
    base = expr.(PointerArithmeticExpr).getPointer()
    or
    // &(array[index]) expressions
    result =
      getMinStatedValue(expr.(AddressOfExpr).getOperand().(PointerArithmeticExpr).getOperand()) and
    base = expr.(AddressOfExpr).getOperand().(PointerArithmeticExpr).getPointer()
    or
    result = getMinStatedValue(expr.(AddExpr).getRightOperand()) and
    base = expr.(AddExpr).getLeftOperand()
    or
    result = -getMinStatedValue(expr.(SubExpr).getRightOperand()) and
    base = expr.(SubExpr).getLeftOperand()
    or
    expr instanceof IncrementOperation and
    result = 1 and
    base = expr.(IncrementOperation).getOperand()
    or
    expr instanceof DecrementOperation and
    result = -1 and
    base = expr.(DecrementOperation).getOperand()
    or
    // fall-back if `expr` is not an arithmetic or pointer arithmetic expression
    not expr instanceof PointerArithmeticExpr and
    not expr.(AddressOfExpr).getOperand() instanceof PointerArithmeticExpr and
    not expr instanceof AddExpr and
    not expr instanceof SubExpr and
    not expr instanceof IncrementOperation and
    not expr instanceof DecrementOperation and
    base = expr and
    result = 0
  }

  private int constOrZero(Expr e) {
    result = e.getValue().toInt()
    or
    not exists(e.getValue().toInt()) and result = 0
  }

  abstract class PointerToObjectSource extends Expr {
    /**
     * Gets the expression that points to the object.
     */
    abstract Expr getPointer();

    /**
     * Gets the expression, if any, that defines the size of the object.
     */
    abstract Expr getSizeExpr();

    /**
     * Gets the size of the object, if it is statically known.
     */
    abstract int getFixedSize();

    /**
     * Holds if the object is not null-terminated.
     */
    abstract predicate isNotNullTerminated();
  }

  private class DynamicAllocationSource extends PointerToObjectSource instanceof AllocationExpr,
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

    override int getFixedSize() { result = getMaxStatedValue(getSizeExpr()) }

    override predicate isNotNullTerminated() { none() }
  }

  /**
   * A `PointerToObjectSource` which is an `AddressOfExpr` to a variable
   * that is not a field or pointer type.
   */
  private class AddressOfExprSource extends PointerToObjectSource instanceof AddressOfExpr {
    AddressOfExprSource() {
      exists(Variable v |
        v = this.getOperand().(VariableAccess).getTarget() and
        not v.getUnderlyingType() instanceof PointerType and
        not v instanceof Field
      )
    }

    override Expr getPointer() { result = this }

    override Expr getSizeExpr() { none() }

    override int getFixedSize() {
      result = min(this.(AddressOfExpr).getOperand().getType().getSize())
    }

    override predicate isNotNullTerminated() { none() }
  }

  /**
   * A `PointerToObjectSource` which is a `VariableAccess` to a static buffer
   */
  private class StaticBufferAccessSource extends PointerToObjectSource instanceof VariableAccess {
    StaticBufferAccessSource() {
      not this.getTarget() instanceof Field and
      not this.getTarget().getUnspecifiedType() instanceof PointerType and
      this.getTarget().getUnderlyingType().(ArrayType).getSize() > 0
    }

    override Expr getPointer() { result = this }

    override Expr getSizeExpr() { none() }

    override int getFixedSize() {
      result = this.(VariableAccess).getTarget().getUnderlyingType().(ArrayType).getSize()
    }

    override predicate isNotNullTerminated() {
      // StringLiteral::getOriginalLength uses Expr::getValue, which implicitly truncates string literal
      // values to the length fitting the buffer they are assigned to, thus breaking the 'obvious' check.
      // Note: `CharArrayInitializedWithStringLiteral` falsely reports the string literal length in certain cases
      // (e.g. when the string literal contains escape characters or on certain compilers), resulting in false-negatives
      exists(CharArrayInitializedWithStringLiteral init |
        init = this.(VariableAccess).getTarget().getInitializer().getExpr() and
        init.getStringLiteralLength() + 1 > init.getContainerLength()
      )
      or
      // if the buffer is not initialized and does not have any memset call zeroing it, it is not null-terminated.
      // note that this heuristic does not evaluate the order of the memset calls made and whether they dominate
      // any use of the buffer by functions requiring it to be null-terminated.
      (
        this.(VariableAccess).getTarget().getUnspecifiedType().(ArrayType).getBaseType() instanceof
          PlainCharType
        or
        this.(VariableAccess).getTarget().getUnspecifiedType().(ArrayType).getBaseType() instanceof
          Wchar_t
      ) and
      not this.(VariableAccess).getTarget() instanceof GlobalVariable and
      not exists(this.(VariableAccess).getTarget().getInitializer()) and
      // exclude any BufferAccessLibraryFunction that writes to the buffer and does not require
      // a null-terminated buffer argument for its write argument
      not exists(
        BufferAccessLibraryFunctionCall fc, BufferAccessLibraryFunction f, int writeParamIndex
      |
        f = fc.getTarget() and
        writeParamIndex = f.getWriteParamIndex() and
        not f.getANullTerminatedParameterIndex(writeParamIndex) and
        fc.getArgument(writeParamIndex) = this.(VariableAccess).getTarget().getAnAccess()
      ) and
      // exclude any buffers that have an assignment, deref, or array expr with a zero constant
      // note: heuristically implemented using getAChild*()
      not exists(AssignExpr assign |
        assign.getRValue().getValue().toInt() = 0 and
        assign.getLValue().getAChild*() = this.(VariableAccess).getTarget().getAnAccess()
      )
      // note: the case of initializers that are not string literals and non-zero constants is not handled here.
      // e.g. char buf[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}; (not null-terminated)
      //      char buf[10] = { 1 }; (not null-terminated)
    }
  }

  /**
   * A `PointerToObjectSource` which is a string literal that is not
   * part of an variable initializer (to deduplicate `StaticBufferAccessSource`)
   */
  private class StringLiteralSource extends PointerToObjectSource instanceof StringLiteral {
    StringLiteralSource() { not this instanceof CharArrayInitializedWithStringLiteral }

    override Expr getPointer() { result = this }

    override Expr getSizeExpr() { none() }

    override int getFixedSize() {
      // (length of the string literal + null terminator) * (size of the base type)
      result =
        this.(StringLiteral).getOriginalLength() *
          this.(StringLiteral).getUnderlyingType().(DerivedType).getBaseType().getSize()
    }

    override predicate isNotNullTerminated() { none() }
  }

  private class PointerToObjectSourceOrSizeToBufferAccessFunctionConfig extends DataFlow::Configuration {
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
      exists(BufferAccess ba, Expr arg |
        (
          arg = ba.(BufferAccessLibraryFunctionCall).getAnArgument() or
          arg = ba.getARelevantExpr()
        ) and
        (
          sink.asExpr() = arg or
          exists(getArithmeticOffsetValue(arg, sink.asExpr()))
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
      // remove flow from `src` to `dst` in a buffer access function call
      // the standard library models such flow through functions such as memcpy, strcpy, etc.
      exists(BufferAccessLibraryFunctionCall fc | node.asExpr() = fc.getReadArg().getAChild*())
      or
      node.asDefiningArgument() instanceof AddressOfExpr
    }
  }

  private predicate hasFlowFromBufferOrSizeExprToUse(Expr source, Expr use) {
    exists(PointerToObjectSourceOrSizeToBufferAccessFunctionConfig config, Expr useOrChild |
      exists(getArithmeticOffsetValue(use, useOrChild)) and
      config.hasFlow(DataFlow::exprNode(source), DataFlow::exprNode(useOrChild))
    )
  }

  private predicate bufferUseComputableBufferSize(
    Expr bufferUse, PointerToObjectSource source, int size
  ) {
    // flow from a PointerToObjectSource for which we can compute the exact size
    size = source.getFixedSize() and
    hasFlowFromBufferOrSizeExprToUse(source, bufferUse)
  }

  private predicate bufferUseNonComputableSize(Expr bufferUse, Expr source) {
    not bufferUseComputableBufferSize(bufferUse, source, _) and
    hasFlowFromBufferOrSizeExprToUse(source.(DynamicAllocationSource), bufferUse)
  }

  /**
   * Relates `sizeExpr`, a buffer access size expresion, to `source`, which is either `sizeExpr`
   * if `sizeExpr` has a stated value, or a `DynamicAllocationSource::getSizeExprSource` for which
   * we can compute the exact size and that has flow to `sizeExpr`.
   */
  private predicate sizeExprComputableSize(Expr sizeExpr, Expr source, int size) {
    // computable direct value, e.g. array_base[10], where "10" is sizeExpr and source.
    size = getMinStatedValue(sizeExpr) and
    source = sizeExpr
    or
    // computable source value that flows to the size expression, e.g. in cases such as the following:
    // size_t sz = 10;
    // malloc(sz);
    // ... sz passed interprocedurally to another function ...
    // use(p, sz + 1);
    size = source.(DynamicAllocationSource).getFixedSize() + getArithmeticOffsetValue(sizeExpr, _) and
    hasFlowFromBufferOrSizeExprToUse(source.(DynamicAllocationSource).getSizeExprSource(_, _),
      sizeExpr)
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

  /**
   * Holds if `arg` refers to the number of characters excluding a null terminator
   */
  bindingset[fc, arg]
  private predicate isArgNumCharacters(BufferAccessLibraryFunctionCall fc, Expr arg) {
    exists(int i |
      arg = fc.getArgument(i) and
      fc.getTarget().(BufferAccessLibraryFunction).getALengthParameterIndex(i)
    )
  }

  /**
   * Returns '1' if `arg` refers to the number of characters excluding a null terminator,
   * otherwise '0' if `arg` refers to the number of characters including a null terminator.
   */
  bindingset[fc, arg]
  private int argNumCharactersOffset(BufferAccess fc, Expr arg) {
    if isArgNumCharacters(fc, arg) then result = 1 else result = 0
  }

  /**
   * Holds if the call `fc` may result in an invalid buffer access due a read buffer being bigger
   * than the write buffer. This heuristic is useful for cases such as strcpy(dst, src).
   */
  predicate isReadBufferSizeGreaterThanWriteBufferSize(
    Expr readBuffer, Expr writeBuffer, int readBufferSize, int writeBufferSize,
    BufferAccessLibraryFunctionCall fc
  ) {
    readBuffer = fc.getReadArg() and
    writeBuffer = fc.getWriteArg() and
    exists(int readSizeMult, int writeSizeMult, int readBufferSizeBase, int writeBufferSizeBase |
      // the read and write buffer sizes must be derived from computable constants
      bufferUseComputableBufferSize(readBuffer, _, readBufferSizeBase) and
      bufferUseComputableBufferSize(writeBuffer, _, writeBufferSizeBase) and
      // calculate the buffer byte sizes (size base is the number of elements)
      readSizeMult = fc.getReadSizeArgMult() and
      writeSizeMult = fc.getWriteSizeArgMult() and
      readBufferSize = readBufferSizeBase - readSizeMult * getArithmeticOffsetValue(readBuffer, _) and
      writeBufferSize =
        writeBufferSizeBase - writeSizeMult * getArithmeticOffsetValue(writeBuffer, _) and
      // the read buffer size is larger than the write buffer size
      readBufferSize > writeBufferSize and
      (
        // if a size arg exists and it is computable, then it must be <= to the write buffer size
        exists(fc.getWriteSizeArg(writeSizeMult))
        implies
        (
          sizeExprComputableSize(fc.getWriteSizeArg(writeSizeMult), _, _) and
          not exists(Expr writeSizeArg, int writeSizeArgValue |
            writeSizeArg = fc.getWriteSizeArg(writeSizeMult) and
            sizeExprComputableSize(writeSizeArg, _, writeSizeArgValue) and
            writeSizeMult.(float) *
              (writeSizeArgValue + argNumCharactersOffset(fc, writeSizeArg)).(float) <=
              writeBufferSize
          )
        )
      )
    )
  }

  /**
   * Holds if `sizeArg` is the right operand of a `PointerSubExpr`
   */
  predicate isSizeArgPointerSubExprRightOperand(Expr sizeArg) {
    exists(PointerSubExpr subExpr | sizeArg = subExpr.getRightOperand())
  }

  /**
   * Holds if the BufferAccess `bufferAccess` results in a buffer overflow due to a size argument
   * or buffer access offset being greater in size than the buffer size being accessed or written to.
   */
  predicate isSizeArgGreaterThanBufferSize(
    Expr bufferArg, Expr sizeArg, PointerToObjectSource bufferSource, int computedBufferSize,
    int computedSizeAccessed, BufferAccess bufferAccess
  ) {
    exists(float sizeMult, int bufferArgSize, int sizeArgValue |
      bufferAccess.hasABuffer(bufferArg, sizeArg, sizeMult) and
      bufferUseComputableBufferSize(bufferArg, bufferSource, bufferArgSize) and
      // If the bufferArg is an access of a static buffer, do not look for "long distance" sources
      (bufferArg instanceof StaticBufferAccessSource implies bufferSource = bufferArg) and
      sizeExprComputableSize(sizeArg, _, sizeArgValue) and
      computedBufferSize = bufferArgSize - sizeMult.(float) * getArithmeticOffsetValue(bufferArg, _) and
      // Handle cases such as *(ptr - 1)
      (
        if isSizeArgPointerSubExprRightOperand(sizeArg)
        then
          computedSizeAccessed =
            sizeMult.(float) *
              (-sizeArgValue + argNumCharactersOffset(bufferAccess, sizeArg)).(float)
        else
          computedSizeAccessed =
            sizeMult.(float) *
              (sizeArgValue + argNumCharactersOffset(bufferAccess, sizeArg)).(float)
      ) and
      computedBufferSize < computedSizeAccessed
    )
  }

  /**
   * Holds if the call `fc` may result in an invalid buffer access due to a buffer argument
   * being accessed at an offset that is greater than the size of the buffer.
   */
  predicate isBufferOffsetGreaterThanBufferSize(
    Expr bufferArg, int bufferArgOffset, int bufferSize, BufferAccessLibraryFunctionCall fc
  ) {
    exists(int bufferElementSize |
      (
        bufferArg = fc.getReadArg() and
        bufferElementSize = fc.getReadSizeArgMult()
        or
        bufferArg = fc.getWriteArg() and
        bufferElementSize = fc.getWriteSizeArgMult()
      ) and
      bufferUseComputableBufferSize(bufferArg, _, bufferSize) and
      bufferArgOffset = getArithmeticOffsetValue(bufferArg, _) * bufferElementSize and
      bufferArgOffset >= bufferSize
    )
  }

  /**
   * Holds if `a` and `b` are function calls to the same target function and
   * have identical arguments (determined by their global value number or `VariableAccess` targets).
   */
  bindingset[a, b]
  private predicate areFunctionCallsSyntacticallySame(FunctionCall a, FunctionCall b) {
    a.getTarget() = b.getTarget() and
    (
      exists(a.getAnArgument())
      implies
      not exists(int i, Expr argA, Expr argB |
        i = [0 .. a.getTarget().getNumberOfParameters() - 1]
      |
        argA = a.getArgument(i) and
        argB = b.getArgument(i) and
        not globalValueNumber(argA) = globalValueNumber(argB) and
        not argA.(VariableAccess).getTarget() = argB.(VariableAccess).getTarget()
      )
    )
  }

  /**
   * Holds if `a` and `b` have the same global value number or are syntactically identical function calls
   */
  bindingset[a, b]
  private predicate isGVNOrFunctionCallSame(Expr a, Expr b) {
    globalValueNumber(a) = globalValueNumber(b)
    or
    areFunctionCallsSyntacticallySame(a, b)
  }

  /**
   * Holds if the BufferAccess is accessed with a `base + accessOffset` on a buffer that was
   * allocated a size of the form `base + allocationOffset`.
   */
  predicate isGVNOffsetGreaterThanBufferSize(
    Expr bufferArg, Expr bufferSizeArg, Expr sourceSizeExpr, int sourceSizeExprOffset,
    int sizeArgOffset, BufferAccessLibraryFunctionCall fc
  ) {
    exists(
      DynamicAllocationSource source, Expr sourceSizeExprBase, int bufferArgOffset, int sizeMult
    |
      (
        bufferArg = fc.getWriteArg() and
        bufferSizeArg = fc.getWriteSizeArg(sizeMult)
        or
        bufferArg = fc.getReadArg() and
        bufferSizeArg = fc.getReadSizeArg(sizeMult)
      ) and
      sourceSizeExpr = source.getSizeExprSource(sourceSizeExprBase, sourceSizeExprOffset) and
      bufferUseNonComputableSize(bufferArg, source) and
      not globalValueNumber(sourceSizeExpr) = globalValueNumber(bufferSizeArg) and
      exists(Expr sizeArgBase |
        sizeArgOffset = getArithmeticOffsetValue(bufferSizeArg.getAChild*(), sizeArgBase) and
        isGVNOrFunctionCallSame(sizeArgBase, sourceSizeExprBase) and
        bufferArgOffset = getArithmeticOffsetValue(bufferArg, _) and
        sourceSizeExprOffset + bufferArgOffset < sizeArgOffset
      )
    )
  }

  /**
   * Holds if the call `fc` may result in an invalid buffer access due to a standard library
   * function being called with a null pointer as a buffer argument while expecting only non-null input.
   */
  predicate isMandatoryBufferArgNull(Expr bufferArg, BufferAccessLibraryFunctionCall fc) {
    exists(int i |
      i =
        [
          fc.getTarget().(BufferAccessLibraryFunction).getReadParamIndex(),
          fc.getTarget().(BufferAccessLibraryFunction).getWriteParamIndex()
        ] and
      not fc.getTarget().(BufferAccessLibraryFunction).getAPermissiblyNullParameterIndex(i) and
      bufferArg = fc.getArgument(i) and
      getMinStatedValue(bufferArg) = 0
    )
  }

  /**
   * Holds if the call `fc` may result in an invalid buffer access due to a standard library function
   * receiving a non-null terminated buffer as a buffer argument and accessing it.
   */
  predicate isNullTerminatorMissingFromArg(
    Expr arg, PointerToObjectSource source, BufferAccessLibraryFunctionCall fc
  ) {
    exists(int i, Expr argChild |
      fc.getTarget().(BufferAccessLibraryFunction).getANullTerminatedParameterIndex(i) and
      fc.getArgument(i) = arg and
      source.isNotNullTerminated() and
      argChild = arg.getAChild*() and
      // ignore cases like strcpy(irrelevant_func(non_null_terminated_str, ...), src)
      not exists(FunctionCall other |
        not other = fc and
        other.getAnArgument().getAChild*() = argChild
      ) and
      hasFlowFromBufferOrSizeExprToUse(source, argChild)
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
      (
        // Not a size expression for which we can compute a specific size
        not sizeExprComputableSize(sizeArg, _, _) and
        // and with a lower bound that is less than zero, taking into account offsets
        lowerBound(sizeArg) + getArithmeticOffsetValue(bufferArg, _) < 0
        or
        // A size expression for which we can compute a specific size and that size is less than zero
        sizeExprComputableSize(sizeArg, _, _) and
        (
          if isSizeArgPointerSubExprRightOperand(sizeArg)
          then -sizeArg.getValue().toInt() + getArithmeticOffsetValue(bufferArg, _) < 0
          else sizeArg.getValue().toInt() + getArithmeticOffsetValue(bufferArg, _) < 0
        )
      )
    )
  }

  private string bufferArgType(BufferAccessLibraryFunctionCall fc, Expr bufferArg) {
    fc.getReadArg() = bufferArg and
    result = "read buffer"
    or
    fc.getWriteArg() = bufferArg and
    result = "write buffer"
  }

  predicate problems(
    BufferAccessLibraryFunctionCall fc, string message, Expr bufferArg, string bufferArgStr,
    Expr sizeOrOtherBufferArg, string otherStr
  ) {
    exists(int bufferArgSize, int sizeArgValue |
      isSizeArgGreaterThanBufferSize(bufferArg, sizeOrOtherBufferArg, _, bufferArgSize,
        sizeArgValue, fc) and
      bufferArgStr = bufferArgType(fc, bufferArg) and
      message =
        "The size of the $@ passed to " + fc.getTarget().getName() + " is " + bufferArgSize +
          " bytes, but the " + "$@ is " + sizeArgValue + " bytes." and
      otherStr = "size argument"
      or
      isBufferOffsetGreaterThanBufferSize(bufferArg, sizeArgValue, bufferArgSize, fc) and
      bufferArgStr = bufferArgType(fc, bufferArg) and
      message =
        "The $@ passed to " + fc.getTarget().getName() + " is " + bufferArgSize +
          " bytes, but an offset of " + sizeArgValue + " bytes is used to access it." and
      otherStr = "" and
      sizeOrOtherBufferArg = bufferArg
    )
    or
    isMandatoryBufferArgNull(bufferArg, fc) and
    message = "The $@ passed to " + fc.getTarget().getName() + " is null." and
    bufferArgStr = "argument" and
    otherStr = "" and
    sizeOrOtherBufferArg = bufferArg
    or
    isNullTerminatorMissingFromArg(bufferArg, _, fc) and
    message = "The $@ passed to " + fc.getTarget().getName() + " might not be null-terminated." and
    bufferArgStr = "argument" and
    otherStr = "" and
    sizeOrOtherBufferArg = bufferArg
    or
    exists(int readBufferSize, int writeBufferSize |
      isReadBufferSizeGreaterThanWriteBufferSize(bufferArg, sizeOrOtherBufferArg, readBufferSize,
        writeBufferSize, fc) and
      message =
        "The size of the $@ passed to " + fc.getTarget().getName() + " is " + readBufferSize +
          " bytes, but the size of the $@ is only " + writeBufferSize + " bytes." and
      bufferArgStr = "read buffer" and
      otherStr = "write buffer"
    )
    or
    exists(int accessOffset, Expr source |
      isGVNOffsetGreaterThanBufferSize(bufferArg, _, source, _, accessOffset, fc) and
      message =
        "The $@ passed to " + fc.getTarget().getName() + " is accessed at an excessive offset of " +
          accessOffset + " element(s) from the $@." and
      bufferArgStr = bufferArgType(fc, bufferArg) and
      sizeOrOtherBufferArg = source and
      otherStr = "allocation size base"
    )
  }
}
