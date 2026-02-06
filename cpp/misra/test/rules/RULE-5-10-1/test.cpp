#include <cstddef>
#include <cstdint>

// Test case for universal character names at start of identifier
void test_universal_character_start() {
  int α = 1;        // COMPLIANT - Greek alpha, XID_Start
  int _beta = 2;    // NON_COMPLIANT - starts with underscore
  int γ42 = 3;      // COMPLIANT - Greek gamma at start
  int ‿invalid = 4; // NON_COMPLIANT - U+203F not in XID_Start class
  int ⁰start = 5;   // NON_COMPLIANT - U+2070 not in XID_Start class
  int א = 6;        // COMPLIANT - Hebrew alef, XID_Start
  int ب = 7;        // COMPLIANT - Arabic beh, XID_Start
  int А = 8;        // COMPLIANT - Cyrillic capital A, XID_Start
  int ひ = 9;       // COMPLIANT - Hiragana hi, XID_Start
  int 中 = 10;      // COMPLIANT - CJK ideograph, XID_Start
}

// Test case for universal character names within identifier
void test_universal_character_continue() {
  int var1 = 1;        // COMPLIANT - normal identifier
  int varα = 2;        // COMPLIANT - XID_Continue character
  int var_γ = 3;       // COMPLIANT - underscore and XID_Continue
  int var⁺invalid = 5; // NON_COMPLIANT - U+207A not in XID_Continue class
  int var̃ = 6; // COMPLIANT - combining tilde, XID_Continue but not XID_Start
  int var‿conn = 7; // COMPLIANT - connector punctuation, XID_Continue
  int var9 = 8;     // COMPLIANT - decimal number, XID_Continue
  int varً = 9;  // COMPLIANT - Arabic fathatan, XID_Continue but not XID_Start
  int var֪ = 10; // COMPLIANT - Hebrew point, XID_Continue but not XID_Start
}

// Test case for Normalization Form C compliance - separate functions to avoid
// redefinition
void test_normalization_form_c_nfc() {
  int café1 = 1;   // COMPLIANT - NFC form (precomposed)
  int naïve1 = 2;  // COMPLIANT - NFC form (precomposed)
  int résumé1 = 3; // COMPLIANT - NFC form (precomposed)
}

void test_normalization_form_c_nfd() {
  int café2 =
      1; // NON_COMPLIANT - NFD form (decomposed é as e + combining acute)
  int naïve2 =
      2; // NON_COMPLIANT - NFD form (decomposed ï as i + combining diaeresis)
  int résumé2 = 3; // NON_COMPLIANT - NFD form (decomposed characters)
}

// Test case for double underscore prohibition
void test_double_underscore() {
  int valid_name = 1; // COMPLIANT
  int __invalid = 2;  // NON_COMPLIANT - contains double underscore
  int val__id = 3;    // NON_COMPLIANT - contains double underscore
  int __end__ = 4;    // NON_COMPLIANT - contains double underscore
}

// Test case for leading underscore prohibition (non-literal suffix)
void test_leading_underscore() {
  int _local = 1;      // NON_COMPLIANT - starts with underscore
  int valid = 2;       // COMPLIANT
  int under_score = 3; // COMPLIANT - underscore not at start
}

// Test case for user-defined literal suffixes
void test_user_defined_literals() {
  // COMPLIANT - proper user-defined literal suffix
  long double operator""_km(long double value) { return value * 1000; }

  // NON_COMPLIANT - user-defined literal suffix doesn't start with underscore
  long double operator"" mil(long double value) { return value; }

  // Space before underscore makes it reserved, however, we can't detect this in
  // the extractor. NON_COMPLIANT[False negative]
  long double operator"" _meter(long double value) { return value; }

  // COMPLIANT - space before quotes does not affect compliance.
  long double operator""_nanometer(long double value) { return value; }

  // clang-format off
  // NON_COMPLIANT - space before underscore makes it reserved, this we can
  // guess with offsets.
  long double operator "" _micrometer(long double value) { return value; }

  // COMPLIANT[False positive] - This confuses our logic that uses spaces to
  // guess offsets.
  long double operator  ""_picometer(long double value) { return value; }

  // NON_COMPLIANT -- not reserved, but required to start with an underscore.
  long double operator "" angstrom(long double value) { return value; }
  // clang-format on

  // COMPLIANT - proper user-defined literal suffix
  int operator""_count(unsigned long long value) {
    return static_cast<int>(value);
  }
}

class C1 {
  // COMPLIANT
  int operator+(int value) {
    return value;
  } // Non-literal suffix, valid operator overload
  int operator++(int value) {
    return value;
  } // Non-literal suffix, valid operator overload
};

// Test case for macro identifier restrictions
#define VALID_MACRO 42       // COMPLIANT - uppercase, numbers, underscore
#define ANOTHER_MACRO_123 43 // COMPLIANT - uppercase, numbers, underscore
#define invalid_macro 44     // NON_COMPLIANT - contains lowercase
#define Mixed_Case 45        // NON_COMPLIANT - contains lowercase
#define VALID_123_MACRO 46   // COMPLIANT
#define MACRO_with_lower 47  // NON_COMPLIANT - mixed case
#define MACRO_123_lower 48   // NON_COMPLIANT - contains lowercase
#define macro_ALL_CAPS 49    // NON_COMPLIANT - starts with lowercase
#define MACRO$DOLLAR 54      // NON_COMPLIANT - contains dollar sign
#define FUNCTION_LIKE_MACRO(x)                                                 \
  ((x) + 1) // NON_COMPLIANT - lower case argument name
#define FUNCTION_LIKE_MACRO2(X)                                                \
  ((X) + 1) // COMPLIANT - upper case argument name
#define VARIADIC_MACRO(X, __VA_ARGS__...) __VA_ARGS__ // COMPLIANT - variadic
#define NOT_VARIADIC_MACRO(X, __Y) __Y // NON_COMPLIANT -- double underscore

// Test case for namespace std restriction (without number)
namespace std { // NON_COMPLIANT - namespace std is reserved
int l1 = 1;
}

// Test case for namespace stdN restriction
namespace test_namespace_std {
int valid_var = 1; // COMPLIANT
}

namespace std42 { // NON_COMPLIANT - namespace stdN
int l2 = 1;
}

namespace std123 { // NON_COMPLIANT - namespace stdN
int l3 = 2;
}

namespace std0 { // NON_COMPLIANT - namespace stdN
int l4 = 3;
}

// Test case for namespace posix restrictions
namespace posix { // NON_COMPLIANT - reserved namespace
int l5 = 4;
}

namespace posix1 { // COMPLIANT - namespace posixN
int l6 = 5;
}

namespace posix42 { // COMPLIANT - namespace posixN
int l7 = 6;
}

namespace posix0 { // COMPLIANT - namespace posixN
int l8 = 7;
}

// Test case for reserved identifier names
void test_reserved_names() {
  int valid_name = 1;    // COMPLIANT
  int final = 2;         // NON_COMPLIANT - reserved name
  int override = 3;      // NON_COMPLIANT - reserved name
  int defined = 4;       // NON_COMPLIANT - reserved name
  int size_t = 5;        // NON_COMPLIANT - reserved name
  int FILE = 6;          // NON_COMPLIANT - reserved name
  int time_t = 7;        // NON_COMPLIANT - reserved name
  int ptrdiff_t = 8;     // NON_COMPLIANT - reserved name
  int clock_t = 9;       // NON_COMPLIANT - reserved name
  int div_t = 10;        // NON_COMPLIANT - reserved name
  int fpos_t = 11;       // NON_COMPLIANT - reserved name
  int lconv = 12;        // NON_COMPLIANT - reserved name
  int ldiv_t = 13;       // NON_COMPLIANT - reserved name
  int mbstate_t = 14;    // NON_COMPLIANT - reserved name
  int sig_atomic_t = 15; // NON_COMPLIANT - reserved name
  int tm = 16;           // NON_COMPLIANT - reserved name
  int va_list = 17;      // NON_COMPLIANT - reserved name
  int wctrans_t = 18;    // NON_COMPLIANT - reserved name
  int wctype_t = 19;     // NON_COMPLIANT - reserved name
  int wint_t = 20;       // NON_COMPLIANT - reserved name
}

// Test case for valid identifiers
void test_valid_identifiers() {
  int validName = 1;      // COMPLIANT
  int valid_name_123 = 2; // COMPLIANT
  int CamelCase = 3;      // COMPLIANT
  int snake_case = 4;     // COMPLIANT
  int name123 = 5;        // COMPLIANT
  int a = 6;              // COMPLIANT
  int Z = 7;              // COMPLIANT
}

// Template specialization test (rule does not apply)
template <typename T> struct hash {};

template <>
struct hash<int> { // COMPLIANT - rule does not apply to template
                   // specializations
  std::size_t operator()(const int &x) const {
    return static_cast<std::size_t>(x);
  }
};