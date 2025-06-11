#include <cstdint>
#include <iostream>

// Global variables for testing
std::uint8_t g1 = 5;
std::uint8_t g2 = 10;
std::uint8_t g3 = 15;
std::uint8_t g4 = 20;
std::int16_t g5 = 100;
std::int32_t g6 = 200;
bool g7 = true;

// Function declarations
std::int32_t f1();
bool f2();
std::int32_t *f3();

// Class with explicit operator bool
class TestClassExplicit {
  std::int32_t m1;

public:
  explicit operator bool() const { return m1 < 0; }
};

class TestClassImplicit {
  std::int32_t m1;

public:
  operator bool() const { return m1 < 0; } // Implicit conversion
};

// Bit-field struct for exception #3
struct BitFieldStruct {
  unsigned int m1 : 1;
};

void test_logical_operators() {
  std::uint8_t l1 = 5;
  std::uint8_t l2 = 10;
  std::uint8_t l3 = 15;
  std::uint8_t l4 = 20;

  if ((l1 < l2) && (l3 < l4)) { // COMPLIANT
  }
  if ((l1 < l2) && (l3 + l4)) { // NON_COMPLIANT
  }
  if (true && (l3 < l4)) { // COMPLIANT
  }
  if (1 && (l3 < l4)) { // NON_COMPLIANT
  }
  if (l1 && (l3 < l4)) { // NON_COMPLIANT
  }
  if (!0) { // NON_COMPLIANT
  }
  if (!false) { // COMPLIANT
  }
  if (l1) { // NON_COMPLIANT
  }
}

void test_conditional_operator() {
  std::int32_t l1 = 100;
  std::int32_t l2 = 200;
  std::int32_t l3 = 300;
  std::int16_t l4 = 50;
  bool l5 = true;

  l1 = l4 ? l2 : l3;       // NON_COMPLIANT
  l1 = l5 ? l2 : l3;       // COMPLIANT
  l1 = (l4 < 5) ? l2 : l3; // COMPLIANT
}

void test_if_statements() {
  std::int32_t l1;
  bool l2 = f2();

  if (std::int32_t l3 = f1()) { // NON_COMPLIANT
  }
  if (std::int32_t l4 = f1(); l4 != 0) { // COMPLIANT
  }
  if (bool l5 = f2()) { // COMPLIANT
  }
  if (std::int32_t l6 = f1(); l6) { // NON_COMPLIANT
  }
}

void test_while_loops() {
  while (std::int32_t l1 = f1()) { // COMPLIANT - exception #4
  }

  for (std::int32_t l2 = 10; l2; --l2) { // NON_COMPLIANT
  }

  while (std::cin) { // COMPLIANT - exception #2
  }
}

void test_pointer_conversions() {
  if (f3()) { // COMPLIANT - exception #2
  }

  bool l1 = f3();            // NON_COMPLIANT
  bool l2 = f3() != nullptr; // COMPLIANT
}

void test_assignment_to_bool() {
  bool l1 = static_cast<bool>(4); // NON_COMPLIANT
  bool l2 = g1;                   // NON_COMPLIANT
  bool l3 = (g1 < g2);            // COMPLIANT
  bool l4 = g7;                   // COMPLIANT
}

void test_class_with_explicit_bool_operator() {
  TestClassExplicit l1;

  bool l2 = static_cast<bool>(l1); // COMPLIANT - exception #1
  if (l1) {                        // COMPLIANT - exception #2
  }
  TestClassImplicit l3;
  bool l4 = l3; // NON_COMPLIANT
}

void test_bitfield_conversion() {
  BitFieldStruct l1;

  bool l2 = l1.m1; // COMPLIANT - exception #3
}

void test_unscoped_enum_conversion() {
  enum Color { RED, GREEN, BLUE };
  Color l1 = RED;

  bool l2 = l1; // NON_COMPLIANT
  if (l1) {     // NON_COMPLIANT
  }
  bool l3 = (l1 == RED); // COMPLIANT
}

void test_scoped_enum_conversion() {
  enum class Status { ACTIVE, INACTIVE };
  Status l1 = Status::ACTIVE;

  bool l2 = (l1 == Status::ACTIVE); // COMPLIANT
}