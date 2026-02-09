#include <cassert>
#include <cctype>
#include <cstdint>
#include <iostream>
#include <locale>
#include <optional>
#include <string>

void test_character_literal_assignment() {
  char l1 = 'a';  // COMPLIANT
  char l2 = '\r'; // COMPLIANT
  char l3 = '\n'; // COMPLIANT
  char l4 = '\0'; // COMPLIANT
}

void test_implicit_conversion_from_int() {
  char l1 = 10; // NON_COMPLIANT
  char l2 = 65; // NON_COMPLIANT
  char l3 = 0;  // NON_COMPLIANT
}

void test_implicit_conversion_to_int() {
  char l1 = 'a';
  std::int8_t l2 = 'a';   // NON_COMPLIANT
  std::uint8_t l3 = '\r'; // NON_COMPLIANT
  int l4 = 'b';           // NON_COMPLIANT
}

void test_signed_char_assignment() {
  signed char l1 = 11; // COMPLIANT
  signed char l2 = 65; // COMPLIANT
}

void test_conversion_between_character_types() {
  char l1 = L'A';    // COMPLIANT
  wchar_t l2 = 'B';  // COMPLIANT
  char16_t l3 = 'C'; // COMPLIANT
  char32_t l4 = 'D'; // COMPLIANT
}

void test_arithmetic_operations() {
  char l1 = 'a';
  char l2 = l1 - '0'; // NON_COMPLIANT
  char l3 = l1 + 1;   // NON_COMPLIANT
  char l4 = l1 * 2;   // NON_COMPLIANT
}

void test_boolean_conversion() {
  char l1 = 'a';
  char l2 = '\0';
  if (l1 && l2) { // NON_COMPLIANT
  }
  if (l1) { // NON_COMPLIANT
  }
  if (!l2) { // NON_COMPLIANT
  }
}

void test_same_type_comparison() {
  char l1 = 'a';
  if (l1 != 'q') { // COMPLIANT
  }
  if (l1 == 'b') { // COMPLIANT
  }
}

void test_char_traits_usage() {
  using CT = std::char_traits<char>;
  char l1 = 'a';
  if (CT::eq(l1, 'q')) { // COMPLIANT
  }
  auto l2 = CT::to_int_type('a');           // COMPLIANT
  auto l3 = static_cast<CT::int_type>('a'); // NON_COMPLIANT
}

void test_optional_comparison() {
  std::optional<char> l1;
  if (l1 == 'r') { // COMPLIANT
  }
}

void test_unevaluated_operand() {
  decltype('s' + 't') l1; // COMPLIANT
  static_assert('x' > 0); // NON_COMPLIANT
  sizeof('x');            // COMPLIANT
}

void test_range_check_non_compliant() {
  char l1 = 'a';
  if ((l1 >= '0') && (l1 <= '9')) { // NON_COMPLIANT
  }
}

void test_range_check_compliant() {
  using CT = std::char_traits<char>;
  char l1 = 'a';
  if (!CT::lt(l1, '0') && !CT::lt('9', l1)) { // COMPLIANT
  }
}

void test_isdigit_non_compliant() {
  char l1 = 'a';
  if (0 == std::isdigit(l1)) { // NON_COMPLIANT
  }
}

void test_isdigit_compliant() {
  char l1 = 'a';
  if (std::isdigit(l1, std::locale{})) { // COMPLIANT
  }
}

void test_stream_conversion() {
  std::istream &l1 = std::cin;
  auto l2 = l1.get();
  using CT = std::char_traits<char>;
  if (CT::not_eof(l2)) {
    char l3 = l2;                   // NON_COMPLIANT
    char l4 = CT::to_char_type(l2); // COMPLIANT
  }
}

void test_explicit_cast() {
  char l1 = static_cast<char>(65); // NON_COMPLIANT
  int l2 = static_cast<int>('A');  // NON_COMPLIANT
}

void test_function_parameter_conversion() {
  auto f1 = [](int l1) {};
  char l2 = 'x';
  f1(l2); // NON_COMPLIANT
}