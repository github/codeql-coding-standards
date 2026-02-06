#include <cstdint>
#include <iostream>

// Test functions
extern int *f();
void f1(double);
void f1(std::uint32_t);
void simple_function();

void test_function_to_pointer_conversion() {
  if (f) { // NON_COMPLIANT
  }

  if (f == nullptr) { // NON_COMPLIANT
  }

  std::cout << std::boolalpha // COMPLIANT - considered assignment
            << f;             // NON_COMPLIANT - not assignment

  // Non-compliant: Unary plus operator causing pointer decay
  auto l1 = +f; // NON_COMPLIANT

  auto lam = []() {};
  // Lambda used in boolean context
  if (lam) { // NON_COMPLIANT
  }

  // Lambda used in address-of operator
  if (&lam) { // COMPLIANT
  }

  // Unary plus on lambda
  auto l2 = +lam; // NON_COMPLIANT

  // Using address-of operator
  if (&f != nullptr) { // COMPLIANT
  }

  // Function call
  (f)(); // COMPLIANT
  lam(); // COMPLIANT

  // static_cast conversion
  auto selected = static_cast<void (*)(std::uint32_t)>(f1); // COMPLIANT

  // Assignment to pointer-to-function type
  void (*p)() = lam; // COMPLIANT

  // Assignment to pointer-to-function type
  int *(*func_ptr)() = f; // COMPLIANT

  // Using address-of operator
  void (*simple_ptr)() = &simple_function; // COMPLIANT

  // Direct assignment without conversion
  void (*simple_ptr2)() = simple_function; // COMPLIANT
}

void test_arithmetic_expressions() {
  // Function used in arithmetic expression (triggers pointer decay)
  auto l3 = f + 0; // NON_COMPLIANT

  // Function used in arithmetic subtraction expression
  auto l4 = f - 0; // NON_COMPLIANT

  // Function used in comparison with non-null pointer
  if (f > nullptr) { // NON_COMPLIANT
  }

  // Function used in relational operators
  if (f < nullptr) { // NON_COMPLIANT
  }

  if (f <= nullptr) { // NON_COMPLIANT
  }

  if (f >= nullptr) { // NON_COMPLIANT
  }
}

void test_logical_expressions() {
  // Function used in logical AND expression
  if (f && true) { // NON_COMPLIANT
  }

  // Function used in logical OR expression
  if (f || false) { // NON_COMPLIANT
  }

  // Lambda used in logical AND expression
  auto lam = []() {};
  if (lam && true) { // NON_COMPLIANT
  }

  // Lambda used in logical OR expression
  if (lam || false) { // NON_COMPLIANT
  }
}