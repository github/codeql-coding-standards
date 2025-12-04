#include <cerrno>
#include <cstdint>
#include <optional>
#include <string>

void errnoSettingFunction();
void handleError();
void f();

#define OK 0
#define CUSTOM_ERROR 42
#define ZERO_MACRO 0

void test_literal_zero_assignment() {
  errno = 0; // COMPLIANT
}

void test_different_zero_literal_formats() {
  errno = 0;   // COMPLIANT - decimal zero literal
  errno = 0x0; // COMPLIANT - hexadecimal zero literal
  errno = 00;  // COMPLIANT - octal zero literal
  errno = 0b0; // COMPLIANT - binary zero literal
}

void test_floating_point_zero_literals() {
  errno = 0.0;  // NON_COMPLIANT - floating point literal, not integer literal
  errno = 0.0f; // NON_COMPLIANT - floating point literal, not integer literal
}

void test_non_zero_literal_assignment() {
  errno = 1;  // NON_COMPLIANT
  errno = 42; // NON_COMPLIANT
  errno = -1; // NON_COMPLIANT
}

void test_macro_assignments() {
  errno = OK;           // COMPLIANT - expands to literal 0
  errno = ZERO_MACRO;   // COMPLIANT - expands to literal 0
  errno = CUSTOM_ERROR; // NON_COMPLIANT - expands to non-zero literal
}

void test_variable_assignments() {
  std::uint32_t l1 = 0;
  const std::uint32_t l2 = 0;
  constexpr std::uint32_t l3 = 0;
  std::uint32_t l4 = 42;
  const std::uint32_t l5 = 42;

  errno = l1; // NON_COMPLIANT - variable, not literal
  errno = l2; // NON_COMPLIANT - constant variable, not literal
  errno = l3; // NON_COMPLIANT - constexpr variable, not literal
  errno = l4; // NON_COMPLIANT - variable with non-zero value
  errno = l5; // NON_COMPLIANT - constant variable with non-zero value
}

void test_standard_error_macros() {
  errno = EINVAL; // NON_COMPLIANT - standard error macro
  errno = ERANGE; // NON_COMPLIANT - standard error macro
  errno = EDOM;   // NON_COMPLIANT - standard error macro
}

void test_expressions() {
  errno = 0 + 0;                     // NON_COMPLIANT - expression, not literal
  errno = 1 - 1;                     // NON_COMPLIANT - expression, not literal
  errno = 0 * 5;                     // NON_COMPLIANT - expression, not literal
  errno = sizeof(int) - sizeof(int); // NON_COMPLIANT - expression, not literal
}

void test_compound_assignments() {
  errno = 5;  // NON_COMPLIANT - initial assignment to non-zero value
  errno += 0; // NON_COMPLIANT - compound assignment, not simple assignment
  errno -= 5; // NON_COMPLIANT - compound assignment, not simple assignment
  errno *= 0; // NON_COMPLIANT - compound assignment, not simple assignment
  errno /= 1; // NON_COMPLIANT - compound assignment, not simple assignment
}

void test_function_return_values() {
  auto l1 = []() { return 0; };
  auto l2 = []() { return 42; };

  errno = l1(); // NON_COMPLIANT - function return value, not literal
  errno = l2(); // NON_COMPLIANT - function return value, not literal
}

void test_cast_expressions() {
  errno = static_cast<int>(0);   // NON_COMPLIANT - cast expression
  errno = static_cast<int>(0.0); // NON_COMPLIANT - cast expression
  errno = (int)0;                // NON_COMPLIANT - C-style cast
  errno = int(0);                // NON_COMPLIANT - functional cast
}

void test_reading_errno_is_allowed() {
  std::uint32_t l1 = errno; // COMPLIANT - reading errno is allowed
  if (errno != 0) {         // COMPLIANT - reading errno is allowed
    handleError();
  }

  errnoSettingFunction();
  std::uint32_t l2 = 0;
  if (errno != l2) { // COMPLIANT - reading errno is allowed
    handleError();
  }
}

void test_pointer_and_null_assignments() {
label:
  static const int x = 0;
  errno = reinterpret_cast<int>(nullptr); // NON_COMPLIANT - nullptr is
                                          // not an integer literal
  errno = reinterpret_cast<int>(&x); // NON_COMPLIANT - pointer cast to integer
  errno = reinterpret_cast<int>(&f); // NON_COMPLIANT - pointer cast to
                                     // integer
  errno = reinterpret_cast<int>(&&label); // NON_COMPLIANT - pointer
                                          // cast to integer
  errno = NULL; // NON_COMPLIANT[FALSE_NEGATIVE] - NULL may expand to 0 but not
                // literal
}

void test_character_literals() {
  errno = '\0'; // NON_COMPLIANT[FALSE_NEGATIVE] - character literal, not
                // integer literal
  errno = '0';  // NON_COMPLIANT - character '0' has value 48
}

void test_boolean_literals() {
  errno = false; // NON_COMPLIANT[FALSE_NEGATIVE] - boolean literal, not integer
                 // literal
  errno = true;  // NON_COMPLIANT - boolean literal with non-zero value
}