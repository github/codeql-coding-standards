#include <cassert>
#include <cstdint>

// Test cases for MISRA C++ 2023 Rule 22.3.1
// The assert macro shall not be used with a constant-expression

void test_assert_with_variable_expression() {
  std::int32_t l1 = 42;
  assert(l1 > 0); // COMPLIANT

  std::int32_t l2 = 100;
  assert(l2 < 1000); // COMPLIANT
}

void test_assert_with_function_call() {
  auto f1 = []() { return true; };
  assert(f1()); // COMPLIANT
}

void test_assert_with_constant_expression() {
  assert(sizeof(int) == 4); // NON_COMPLIANT
  assert(true);             // NON_COMPLIANT
  assert(1 + 1 == 2);       // NON_COMPLIANT
  assert(42 > 0);           // NON_COMPLIANT
}

void test_assert_with_constant_expression_and_string() {
  assert((sizeof(int) == 4) && "Bad size"); // NON_COMPLIANT
  assert(true && "Always true");            // NON_COMPLIANT
  assert((1 + 1 == 2) && "Math works");     // NON_COMPLIANT
}

void test_assert_false_exception() {
  assert(false);                            // COMPLIANT
  assert(false && "Unexpected path");       // COMPLIANT
  assert(false && "Should not reach here"); // COMPLIANT
}

void test_assert_with_mixed_expressions() {
  std::int32_t l1 = 10;
  // When dynamic and constant expressions are mixed, we treat the assertion as
  // compliant.
  //
  // Technically, some cases such as `assert(dynamic && static)` is equivalent
  // to `assert(dynamic); assert(static)` and we could report them. However,
  // other cases such as `assert(dynamic || static)` are *not* equivalent to any
  // standalone static assertion.
  //
  // Distinguishing these cases correctly in all cases is non-trivial, so we do
  // not report any mixed cases at this time.
  //
  // We do not consider the following cases to be false negatives:
  assert(l1 > 0 && sizeof(int) == 8); // COMPLIANT
  assert(sizeof(int) == 4 && l1 > 0); // COMPLIANT
  // Because they are difficult to distinguish from the following, which are
  // clearly compliant:
  assert(l1 > 0 || sizeof(int) == 4); // COMPLIANT
  assert(sizeof(int) == 8 || l1 > 0); // COMPLIANT
}

void test_assert_with_template_constant() {
  constexpr std::int32_t l1 = 42;
  assert(l1 == 42); // NON_COMPLIANT
}

void test_assert_with_enum_constant() {
  enum { VALUE = 10 };
  assert(VALUE == 10); // NON_COMPLIANT
}

class TestClass {
public:
  static constexpr std::int32_t m1 = 5;

  void test_assert_with_static_member() {
    assert(m1 == 5);           // NON_COMPLIANT
    assert(TestClass::m1 > 0); // NON_COMPLIANT
  }
};

void test_assert_with_nullptr_constant() {
  assert(nullptr == nullptr); // NON_COMPLIANT
}

void test_assert_with_character_literal() {
  assert('a' == 97); // NON_COMPLIANT
  assert('A' < 'Z'); // NON_COMPLIANT
}

void test_assert_with_string_literal_comparison() {
  const char *l1 = "test";
  assert(l1 != nullptr); // COMPLIANT
}