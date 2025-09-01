#include <cstdint>
#include <string>

// Test non-numeric type categories - these should not trigger rule violations
void test_non_numeric_type_categories() {
  // Character category types
  char l1 = 'a';
  wchar_t l2 = L'b';
  char16_t l3 = u'c';
  char32_t l4 = U'd';

  // Other category types
  bool l5 = true;
  void *l6 = nullptr;
  std::nullptr_t l7 = nullptr;

  // Assignments between character types and numeric types
  // Rule should not apply since source/target involve non-numeric types
  std::uint8_t l8 = 42;
  std::int32_t l9 = 100;
  float l10 = 3.14f;

  // Character to numeric - rule does not apply
  l8 = l1;  // COMPLIANT - char is character category, not numeric
  l9 = l2;  // COMPLIANT - wchar_t is character category, not numeric
  l8 = l3;  // COMPLIANT - char16_t is character category, not numeric
  l9 = l4;  // COMPLIANT - char32_t is character category, not numeric
  l10 = l1; // COMPLIANT - char is character category, not numeric

  // Numeric to character - rule does not apply
  l1 = l8;  // COMPLIANT - char is character category, not numeric
  l2 = l9;  // COMPLIANT - wchar_t is character category, not numeric
  l3 = l8;  // COMPLIANT - char16_t is character category, not numeric
  l4 = l9;  // COMPLIANT - char32_t is character category, not numeric
  l1 = l10; // COMPLIANT - char is character category, not numeric

  // Other category to numeric - rule does not apply
  l8 = l5;  // COMPLIANT - bool is other category, not numeric
  l9 = l5;  // COMPLIANT - bool is other category, not numeric
  l10 = l5; // COMPLIANT - bool is other category, not numeric

  // Numeric to other category - rule does not apply
  l5 = l8;  // COMPLIANT - bool is other category, not numeric
  l5 = l9;  // COMPLIANT - bool is other category, not numeric
  l5 = l10; // COMPLIANT - bool is other category, not numeric

  // Character to character - rule does not apply
  l1 = l2; // COMPLIANT - both character category, not numeric
  l3 = l4; // COMPLIANT - both character category, not numeric
  l1 = l3; // COMPLIANT - both character category, not numeric

  // Other to other - rule does not apply
  std::nullptr_t l11 = l7; // COMPLIANT - both other category, not numeric
  l6 = l7;                 // COMPLIANT - both other category, not numeric

  // Character to other - rule does not apply
  l5 = l1;      // COMPLIANT - neither is numeric category
  l6 = nullptr; // COMPLIANT - neither is numeric category

  // Other to character - rule does not apply
  l1 = l5; // COMPLIANT - neither is numeric category
}

// Test function parameters with non-numeric types
void f15(char l1) {}
void f16(bool l1) {}
void f17(wchar_t l1) {}

void test_non_numeric_function_parameters() {
  std::uint8_t l1 = 42;
  std::int32_t l2 = 100;
  char l3 = 'x';
  bool l4 = true;
  wchar_t l5 = L'y';

  // Function calls with non-numeric parameters - rule does not apply
  f15(l1); // COMPLIANT - parameter is character category, not numeric
  f15(l2); // COMPLIANT - parameter is character category, not numeric
  f15(l3); // COMPLIANT - parameter is character category, not numeric

  f16(l1); // COMPLIANT - parameter is other category, not numeric
  f16(l2); // COMPLIANT - parameter is other category, not numeric
  f16(l4); // COMPLIANT - parameter is other category, not numeric

  f17(l1); // COMPLIANT - parameter is character category, not numeric
  f17(l2); // COMPLIANT - parameter is character category, not numeric
  f17(l5); // COMPLIANT - parameter is character category, not numeric
}

// Test references to non-numeric types
void test_non_numeric_references() {
  char l1 = 'a';
  bool l2 = true;
  wchar_t l3 = L'b';
  std::uint8_t l4 = 42;
  std::int32_t l5 = 100;

  char &l6 = l1;
  bool &l7 = l2;
  wchar_t &l8 = l3;

  // Assignments involving references to non-numeric types - rule does not apply
  l4 = l6; // COMPLIANT - reference to character category, not numeric
  l5 = l7; // COMPLIANT - reference to other category, not numeric
  l4 = l8; // COMPLIANT - reference to character category, not numeric

  l6 = l4; // COMPLIANT - reference to character category, not numeric
  l7 = l5; // COMPLIANT - reference to other category, not numeric
  l8 = l4; // COMPLIANT - reference to character category, not numeric
}

// Test bit-fields with non-numeric types (though these are rare in practice)
struct NonNumericBitFields {
  bool m1 : 1;     // Other category
  char m2 : 7;     // Character category
  wchar_t m3 : 16; // Character category
};

void test_non_numeric_bitfields() {
  NonNumericBitFields l1;
  std::uint8_t l2 = 42;
  std::int32_t l3 = 100;
  bool l4 = true;
  char l5 = 'x';

  // Assignments to/from non-numeric bit-fields - rule does not apply
  l1.m1 = l2; // COMPLIANT - bit-field is other category, not numeric
  l1.m1 = l4; // COMPLIANT - bit-field is other category, not numeric
  l1.m2 = l2; // COMPLIANT - bit-field is character category, not numeric
  l1.m2 = l5; // COMPLIANT - bit-field is character category, not numeric
  l1.m3 = l3; // COMPLIANT - bit-field is character category, not numeric

  l2 = l1.m1; // COMPLIANT - bit-field is other category, not numeric
  l4 = l1.m1; // COMPLIANT - bit-field is other category, not numeric
  l2 = l1.m2; // COMPLIANT - bit-field is character category, not numeric
  l5 = l1.m2; // COMPLIANT - bit-field is character category, not numeric
  l3 = l1.m3; // COMPLIANT - bit-field is character category, not numeric
}