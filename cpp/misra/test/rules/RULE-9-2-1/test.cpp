#include <cstdint>
#include <memory>
#include <mutex>

std::mutex g1;
std::mutex g2;

void f1(std::unique_lock<std::mutex> l1) {
  // Function parameter for testing compliant cases
}

void test_explicit_type_conversion_expression_statement() {
  // Compliant cases - declarations
  std::unique_lock<std::mutex> l1(g1); // COMPLIANT
  std::unique_lock<std::mutex> l2{g1}; // COMPLIANT
  std::unique_lock<std::mutex>(l3);    // COMPLIANT - declaration with redundant
                                       // parentheses around variable name

  // Non-compliant cases - explicit type conversions as expression statements
  std::unique_lock<std::mutex>{g1}; // NON_COMPLIANT
  std::scoped_lock{g1};             // NON_COMPLIANT
  std::scoped_lock(g1, g2);         // NON_COMPLIANT
  std::lock_guard<std::mutex>{g1};  // NON_COMPLIANT

  // Compliant cases - type conversions not as expression statements
  f1(std::unique_lock<std::mutex>(g1));       // COMPLIANT
  f1(std::unique_lock<std::mutex>{g1});       // COMPLIANT
  auto l4 = std::unique_lock<std::mutex>(g1); // COMPLIANT
  auto l5 = std::unique_lock<std::mutex>{g1}; // COMPLIANT

  // The extractor has a bug as of 2.20.7 which means it does not parse
  // these two cases separately. We choose to ignore if statements, which
  // can cause false negatives, but will prevent false positives
  if (std::unique_lock<std::mutex>(g1); true) { // COMPLIANT - init-statement
  }
  if (std::unique_lock<std::mutex>{g1}; true) { // NON_COMPLIANT[FALSE_NEGATIVE]
  }

  for (std::unique_lock<std::mutex>(g1);;) { // COMPLIANT - init-statement
    break;
  }
  for (std::unique_lock<std::mutex>{g1};;) { // NON_COMPLIANT - init-statement
    break;
  }
}

void test_primitive_type_conversions() {
  // Non-compliant cases with primitive types
  std::int32_t(42); // NON_COMPLIANT
  float(3.14);      // NON_COMPLIANT
  double(2.71);     // NON_COMPLIANT
  bool(true);       // NON_COMPLIANT

  // Compliant cases
  auto l1 = std::int32_t(42); // COMPLIANT
  auto l2 = float(3.14);      // COMPLIANT
  std::int32_t l3(42);        // COMPLIANT - declaration
  std::int32_t l4{42};        // COMPLIANT - declaration
}

struct CustomType {
  CustomType(std::int32_t) {}
};
void test_custom_types() {
  // Non-compliant cases
  CustomType(42); // NON_COMPLIANT
  CustomType{42}; // NON_COMPLIANT

  // Compliant cases
  CustomType l1(42);        // COMPLIANT - declaration
  CustomType l2{42};        // COMPLIANT - declaration
  auto l3 = CustomType(42); // COMPLIANT
  auto l4 = CustomType{42}; // COMPLIANT
}