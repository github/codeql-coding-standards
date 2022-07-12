/**
 * A module for modeling classes, member variables, and functions related to character streams in
 * the C++ Standard Library.
 *
 * A character stream is a template instantiation of `std::basic_istream` that is instantiated with
 * a character type, such as `char` or `wchar_t`. This module identifies such instantiations as
 * `CharIStream`s. It also models various features of character streams, including:
 *  - Identifying various types of "extraction operator" (i.e. `operator>>`) related to such
 *    streams.
 *  - The `std::ios_base::iostate` class, used to represent the error state of a stream.
 *  - Calls to `std::basic_ios::exceptions`, which uses bitfield flags to configure which errors
 *    trigger exceptions to be thrown.
 *  - Calls to various error state checking functions (`fail()`,`good()`, `operator!` etc.).
 */

import cpp

/**
 * A `basic_istream` which is instantiated with a char type.
 *
 * For example:
 * ```
 * basic_istream<char>
 * basic_istream<wchar>
 * ```
 */
class CharIStream extends ClassTemplateInstantiation {
  CharIStream() {
    getTemplate().hasQualifiedName("std", "basic_istream") and
    (
      getTemplateArgument(0) instanceof CharType or
      getTemplateArgument(0) instanceof Wchar_t
    )
  }
}

/**
 * A `CharIStream` _extraction operator_ (`operator>>`).
 */
class CharIStreamExtractionOperator extends Operator {
  CharIStreamExtractionOperator() {
    (
      // Operator declared in the `basic_istream` class
      getDeclaringType() instanceof CharIStream
      or
      // Operator declared outside the `basic_istream` class, therefore the first parameter will be
      // a reference to the `basic_istream` class.
      getNumberOfParameters() = 2 and
      getParameter(0).getType().getUnderlyingType().(ReferenceType).getBaseType() instanceof
        CharIStream
    ) and
    hasName("operator>>")
  }
}

/**
 * A call to a `CharIStream` _extraction operator_ (`operator>>`).
 */
class CharIStreamExtractionOperatorCall extends FunctionCall {
  CharIStreamExtractionOperatorCall() { getTarget() instanceof CharIStreamExtractionOperator }

  /**
   * Get the `CharIStream` expression on which `operator>>` is called.
   */
  Expr getStream() {
    result = getQualifier()
    or
    result = getArgument(0) and getNumberOfArguments() = 2
  }
}

/**
 * A `CharIStream` _extraction operator_ (`operator>>`) for numeric values.
 *
 * This converts the next values in the stream to the given type.
 *
 * For example, the target of `>>` in:
 * ```
 * std::stringstream s("1234");
 * int x;
 * s >> x;
 * ```
 */
class CharIStreamNumericExtractionOperator extends CharIStreamExtractionOperator {
  CharIStreamNumericExtractionOperator() {
    getDeclaringType() instanceof CharIStream and
    hasName("operator>>") and
    exists(Type parameterBaseType |
      parameterBaseType =
        getParameter(0).getType().getUnspecifiedType().(ReferenceType).getBaseType()
    |
      parameterBaseType instanceof ArithmeticType
      or
      // Counted as an arithmetic type for operator>>
      parameterBaseType instanceof VoidPointerType
    )
  }
}

/**
 * A call to a `CharIStream` _extraction operator_ (`operator>>`) for numeric values.
 *
 * For example, the call to `operator>>` in:
 * ```
 * std::stringstream s("1234");
 * int x;
 * s >> x;
 * ```
 */
class CharIStreamNumericExtractionOperatorCall extends CharIStreamExtractionOperatorCall {
  CharIStreamNumericExtractionOperatorCall() {
    getTarget() instanceof CharIStreamNumericExtractionOperator
  }
}

/**
 * The `std::basic_ios::exceptions(iostate except)` function.
 *
 * This function sets whether exceptions are thrown on stream errors, and which errors.
 */
class CharIStreamExceptions extends Function {
  CharIStreamExceptions() {
    hasQualifiedName("std", "basic_ios", "exceptions") and
    getNumberOfParameters() = 1
  }
}

/**
 * A module related to `std::ios_base::iostate`.
 *
 * `iostate` is the bitfield the represents different types of error.
 */
module IOState {
  /**
   * An `std::ios_base::iostate` flag.
   */
  newtype TFlag =
    BadBit() or // loss of integrity
    EofBit() or // end of input reached
    FailBit() or // failed to read/generate expected characters
    GoodBit() // no errors

  /**
   * An `std::ios_base::iostate` flag.
   */
  class Flag extends TFlag {
    // name of the const field in `std::ios_base`.
    string fieldName;

    Flag() {
      this = BadBit() and fieldName = "badbit"
      or
      this = EofBit() and fieldName = "eofbit"
      or
      this = FailBit() and fieldName = "failbit"
      or
      this = GoodBit() and fieldName = "goodbit"
    }

    /**
     * Gets the constant value representing this field, if available for the underlying type chosen
     * by the current C++ Standard Library implementation.
     */
    string getValue() {
      exists(MemberVariable mv | mv.hasQualifiedName("std", "ios_base", fieldName) |
        // Constant value may not be available, for example if std::bitset is chosen as the underlying
        // representation
        result = mv.getInitializer().getExpr().getValue()
      )
    }

    string toString() { result = fieldName }
  }
}

/**
 * A call to the `std::basic_ios::exceptions` member function.
 */
class CharIStreamExceptionsCall extends FunctionCall {
  CharIStreamExceptionsCall() { getTarget() instanceof CharIStreamExceptions }

  /**
   * Gets an `iostate` flag which is enabled by this `exceptions` call.
   */
  IOState::Flag getAnEnabledFlag() {
    /*
     * `iostate` is a bitmask type ([bitmask.type]), which can be implemented either as:
     *  - an enumerated type that overloads certain operators
     *  - an integer type
     *  - a std::bitset
     *
     * In the first two cases, assuming sensible implementations of the various operators, the
     * bitmask passed to `exceptions` should generally be a constant, and therefore have a
     * `getValue()`, which we can inspect to determine which flags are enabled.
     *
     * In the std::bitset case, we cannot rely on constant expression evaluation, we assume any
     * flag is possible. At the time of writing gcc uses an enumerated type and clang uses an
     * integer type.
     */

    if exists(getAnEnabledFlagFromConstValue())
    then result = getAnEnabledFlagFromConstValue()
    else
      // We don't have a constant representation of the `iostate` bitmask, so we assume any flag is
      // possible
      any()
  }

  private IOState::Flag getAnEnabledFlagFromConstValue() {
    exists(int bitflagsSet, int iostateFlag |
      bitflagsSet = getArgument(0).getValue().toInt() and iostateFlag = result.getValue().toInt()
    |
      iostateFlag = bitflagsSet // only this flag is set
      or
      iostateFlag.bitAnd(bitflagsSet) = iostateFlag and // this flag is set with others
      not result instanceof IOState::GoodBit // We don't want to return GoodBit if any other flags are set
    )
  }
}

/**
 * A direct call which validates whether a `basic_ios` stream is in an error state.
 */
abstract class StreamErrorStateCheckDirectCall extends FunctionCall {
  /** Gets a */
  Expr getACheckedStream() { result = getQualifier*() }
}

/**
 * A call to `std::basic_ios::fail`, which indicates if the `failbit` or `badbit` is set.
 */
class IosFailCall extends StreamErrorStateCheckDirectCall {
  IosFailCall() { getTarget().hasQualifiedName("std", "basic_ios", "fail") }
}

/**
 * A call to `std::basic_ios::good`, which indicates if the error state is equal to `goodbit`.
 */
class IosGoodCall extends StreamErrorStateCheckDirectCall {
  IosGoodCall() { getTarget().hasQualifiedName("std", "basic_ios", "good") }
}

/**
 * A call to `operator bool()` on `std::ios_base`, which returns `!fail()`.
 */
class IosOperatorBooleanCall extends StreamErrorStateCheckDirectCall {
  IosOperatorBooleanCall() { getTarget().hasQualifiedName("std", "basic_ios", "operator bool") }
}

/**
 * A call to `operator!` on `std::ios_base`, which returns `fail()`.
 */
class IosOperatorNegationCall extends StreamErrorStateCheckDirectCall {
  IosOperatorNegationCall() { getTarget().hasQualifiedName("std", "basic_ios", "operator!") }
}
