import cpp as default

/*
 * Implementations of the C/C++ Fixed Width Types from cstdint.h.
 *
 * TODO: Deprecate once this is available in the CodeQL standard library.
 */

/**
 * A parent class representing C/C++ a typedef'd `UserType` such as `int8_t`.
 */
abstract private class IntegralUnderlyingUserType extends default::UserType {
  IntegralUnderlyingUserType() { this.getUnderlyingType() instanceof default::IntegralType }
}

abstract private class TFixedWidthIntegralType extends IntegralUnderlyingUserType { }

/**
 * A C/C++ fixed-width numeric type, such as `int8_t`.
 */
class FixedWidthIntegralType extends TFixedWidthIntegralType {
  FixedWidthIntegralType() { this instanceof TFixedWidthIntegralType }
}

abstract private class TMinimumWidthIntegralType extends IntegralUnderlyingUserType { }

/**
 * A C/C++ minimum-width numeric type, such as `int_least8_t`.
 */
class MinimumWidthIntegralType extends TMinimumWidthIntegralType {
  MinimumWidthIntegralType() { this instanceof TMinimumWidthIntegralType }
}

abstract private class TFastestMinimumWidthIntegralType extends IntegralUnderlyingUserType { }

/**
 * A C/C++ minimum-width numeric type, representing the fastest integer type with a
 * width of at least `N` such as `int_fast8_t`.
 */
class FastestMinimumWidthIntegralType extends TFastestMinimumWidthIntegralType {
  FastestMinimumWidthIntegralType() { this instanceof TFastestMinimumWidthIntegralType }
}

/**
 * An enum type based on a fixed-width integer type. For instance, `enum e: uint8_t = { a, b };`
 */
class FixedWidthEnumType extends default::UserType {
  FixedWidthEnumType() {
    this.(default::Enum).getExplicitUnderlyingType() instanceof FixedWidthIntegralType
  }
}

/**
 *  The C/C++ `int8_t` type.
 */
class Int8_t extends TFixedWidthIntegralType {
  Int8_t() { this.hasGlobalOrStdName("int8_t") }

  override string getAPrimaryQlClass() { result = "Int8_t" }
}

/**
 *  The C/C++ `int16_t` type.
 */
class Int16_t extends TFixedWidthIntegralType {
  Int16_t() { this.hasGlobalOrStdName("int16_t") }

  override string getAPrimaryQlClass() { result = "Int16_t" }
}

/**
 *  The C/C++ `int32_t` type.
 */
class Int32_t extends TFixedWidthIntegralType {
  Int32_t() { this.hasGlobalOrStdName("int32_t") }

  override string getAPrimaryQlClass() { result = "Int32_t" }
}

/**
 *  The C/C++ `int64_t` type.
 */
class Int64_t extends TFixedWidthIntegralType {
  Int64_t() { this.hasGlobalOrStdName("int64_t") }

  override string getAPrimaryQlClass() { result = "Int64_t" }
}

/**
 *  The C/C++ `uint8_t` type.
 */
class UInt8_t extends TFixedWidthIntegralType {
  UInt8_t() { this.hasGlobalOrStdName("uint8_t") }

  override string getAPrimaryQlClass() { result = "UInt8_t" }
}

/**
 *  The C/C++ `uint16_t` type.
 */
class UInt16_t extends TFixedWidthIntegralType {
  UInt16_t() { this.hasGlobalOrStdName("uint16_t") }

  override string getAPrimaryQlClass() { result = "UInt16_t" }
}

/**
 *  The C/C++ `uint32_t` type.
 */
class UInt32_t extends TFixedWidthIntegralType {
  UInt32_t() { this.hasGlobalOrStdName("uint32_t") }

  override string getAPrimaryQlClass() { result = "UInt32_t" }
}

/**
 *  The C/C++ `uint64_t` type.
 */
class UInt64_t extends TFixedWidthIntegralType {
  UInt64_t() { this.hasGlobalOrStdName("uint64_t") }

  override string getAPrimaryQlClass() { result = "UInt64_t" }
}

/**
 *  The C/C++ `int_least8_t` type.
 */
class Int_least8_t extends TMinimumWidthIntegralType {
  Int_least8_t() { this.hasGlobalOrStdName("int_least8_t") }

  override string getAPrimaryQlClass() { result = "Int_least8_t" }
}

/**
 *  The C/C++ `int_least16_t` type.
 */
class Int_least16_t extends TMinimumWidthIntegralType {
  Int_least16_t() { this.hasGlobalOrStdName("int_least16_t") }

  override string getAPrimaryQlClass() { result = "Int_least16_t" }
}

/**
 *  The C/C++ `int_least32_t` type.
 */
class Int_least32_t extends TMinimumWidthIntegralType {
  Int_least32_t() { this.hasGlobalOrStdName("int_least32_t") }

  override string getAPrimaryQlClass() { result = "Int_least32_t" }
}

/**
 *  The C/C++ `int_least64_t` type.
 */
class Int_least64_t extends TMinimumWidthIntegralType {
  Int_least64_t() { this.hasGlobalOrStdName("int_least64_t") }

  override string getAPrimaryQlClass() { result = "Int_least64_t" }
}

/**
 *  The C/C++ `uint_least8_t` type.
 */
class UInt_least8_t extends TMinimumWidthIntegralType {
  UInt_least8_t() { this.hasGlobalOrStdName("uint_least8_t") }

  override string getAPrimaryQlClass() { result = "UInt_least8_t" }
}

/**
 *  The C/C++ `uint_least16_t` type.
 */
class UInt_least16_t extends TMinimumWidthIntegralType {
  UInt_least16_t() { this.hasGlobalOrStdName("uint_least16_t") }

  override string getAPrimaryQlClass() { result = "UInt_least16_t" }
}

/**
 *  The C/C++ `uint_least32_t` type.
 */
class UInt_least32_t extends TMinimumWidthIntegralType {
  UInt_least32_t() { this.hasGlobalOrStdName("uint_least32_t") }

  override string getAPrimaryQlClass() { result = "UInt_least32_t" }
}

/**
 *  The C/C++ `uint_least64_t` type.
 */
class UInt_least64_t extends TMinimumWidthIntegralType {
  UInt_least64_t() { this.hasGlobalOrStdName("uint_least64_t") }

  override string getAPrimaryQlClass() { result = "UInt_least64_t" }
}

/**
 *  The C/C++ `int_fast8_t` type.
 */
class Int_fast8_t extends TFastestMinimumWidthIntegralType {
  Int_fast8_t() { this.hasGlobalOrStdName("int_fast8_t") }

  override string getAPrimaryQlClass() { result = "Int_fast8_t" }
}

/**
 *  The C/C++ `int_fast16_t` type.
 */
class Int_fast16_t extends TFastestMinimumWidthIntegralType {
  Int_fast16_t() { this.hasGlobalOrStdName("int_fast16_t") }

  override string getAPrimaryQlClass() { result = "Int_fast16_t" }
}

/**
 *  The C/C++ `int_fast32_t` type.
 */
class Int_fast32_t extends TFastestMinimumWidthIntegralType {
  Int_fast32_t() { this.hasGlobalOrStdName("int_fast32_t") }

  override string getAPrimaryQlClass() { result = "Int_fast32_t" }
}

/**
 *  The C/C++ `int_fast64_t` type.
 */
class Int_fast64_t extends TFastestMinimumWidthIntegralType {
  Int_fast64_t() { this.hasGlobalOrStdName("int_fast64_t") }

  override string getAPrimaryQlClass() { result = "Int_fast64_t" }
}

/**
 *  The C/C++ `uint_fast8_t` type.
 */
class UInt_fast8_t extends TFastestMinimumWidthIntegralType {
  UInt_fast8_t() { this.hasGlobalOrStdName("uint_fast8_t") }

  override string getAPrimaryQlClass() { result = "UInt_fast8_t" }
}

/**
 *  The C/C++ `uint_fast16_t` type.
 */
class UInt_fast16_t extends TFastestMinimumWidthIntegralType {
  UInt_fast16_t() { this.hasGlobalOrStdName("uint_fast16_t") }

  override string getAPrimaryQlClass() { result = "UInt_fast16_t" }
}

/**
 *  The C/C++ `uint_fast32_t` type.
 */
class UInt_fast32_t extends TFastestMinimumWidthIntegralType {
  UInt_fast32_t() { this.hasGlobalOrStdName("uint_fast32_t") }

  override string getAPrimaryQlClass() { result = "UInt_fast32_t" }
}

/**
 *  The C/C++ `uint_fast64_t` type.
 */
class UInt_fast64_t extends TFastestMinimumWidthIntegralType {
  UInt_fast64_t() { this.hasGlobalOrStdName("uint_fast64_t") }

  override string getAPrimaryQlClass() { result = "UInt_fast64_t" }
}

/**
 * Type that models a type that is either a pointer or a reference type.
 */
class PointerOrReferenceType extends default::DerivedType {
  PointerOrReferenceType() {
    this instanceof default::PointerType or
    this instanceof default::ReferenceType
  }
}

/**
 * Type that models a char type that is explicitly signed or unsigned.
 */
class ExplictlySignedOrUnsignedCharType extends default::CharType {
  ExplictlySignedOrUnsignedCharType() {
    isExplicitlySigned() or
    isExplicitlyUnsigned()
  }
}
