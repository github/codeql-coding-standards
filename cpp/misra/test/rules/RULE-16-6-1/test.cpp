#include <cstdint>
#include <iostream>

class TestClass {
  std::int32_t value;

public:
  TestClass(std::int32_t v = 0) : value(v) {}

  // NON-COMPLIANT: Symmetrical operators as member functions
  TestClass operator+(const TestClass &rhs) const; // NON_COMPLIANT
  TestClass operator-(const TestClass &rhs) const; // NON_COMPLIANT
  TestClass operator*(const TestClass &rhs) const; // NON_COMPLIANT
  TestClass operator/(const TestClass &rhs) const; // NON_COMPLIANT
  TestClass operator%(const TestClass &rhs) const; // NON_COMPLIANT

  bool operator==(const TestClass &rhs) const; // NON_COMPLIANT
  bool operator!=(const TestClass &rhs) const; // NON_COMPLIANT
  bool operator<(const TestClass &rhs) const;  // NON_COMPLIANT
  bool operator<=(const TestClass &rhs) const; // NON_COMPLIANT
  bool operator>=(const TestClass &rhs) const; // NON_COMPLIANT
  bool operator>(const TestClass &rhs) const;  // NON_COMPLIANT

  TestClass operator^(const TestClass &rhs) const; // NON_COMPLIANT
  TestClass operator&(const TestClass &rhs) const; // NON_COMPLIANT
  TestClass operator|(const TestClass &rhs) const; // NON_COMPLIANT

  bool operator&&(const TestClass &rhs) const; // NON_COMPLIANT
  bool operator||(const TestClass &rhs) const; // NON_COMPLIANT

  // NON-COMPLIANT: Mixed type symmetrical operators as members
  TestClass operator+(std::int32_t rhs) const; // NON_COMPLIANT
  bool operator==(std::int32_t rhs) const;     // NON_COMPLIANT

  // COMPLIANT: Hidden friend operators (non-member but defined in class)
  friend TestClass operator+(const TestClass &lhs,
                             const TestClass &rhs) { // COMPLIANT
    return TestClass(lhs.value + rhs.value);
  }

  friend bool operator==(const TestClass &lhs,
                         const TestClass &rhs) { // COMPLIANT
    return lhs.value == rhs.value;
  }

  // COMPLIANT: Non-symmetrical operators as members are allowed
  TestClass &operator+=(const TestClass &rhs); // COMPLIANT
  TestClass &operator-=(const TestClass &rhs); // COMPLIANT
  TestClass &operator*=(const TestClass &rhs); // COMPLIANT
  TestClass &operator/=(const TestClass &rhs); // COMPLIANT
  TestClass &operator%=(const TestClass &rhs); // COMPLIANT

  TestClass &operator^=(const TestClass &rhs); // COMPLIANT
  TestClass &operator&=(const TestClass &rhs); // COMPLIANT
  TestClass &operator|=(const TestClass &rhs); // COMPLIANT

  TestClass &operator++();   // COMPLIANT
  TestClass operator++(int); // COMPLIANT
  TestClass &operator--();   // COMPLIANT
  TestClass operator--(int); // COMPLIANT

  TestClass operator~() const; // COMPLIANT
  bool operator!() const;      // COMPLIANT

  TestClass &operator=(const TestClass &rhs); // COMPLIANT

  // COMPLIANT: Stream operators are not symmetrical
  friend std::ostream &operator<<(std::ostream &os,
                                  const TestClass &tc);             // COMPLIANT
  friend std::istream &operator>>(std::istream &is, TestClass &tc); // COMPLIANT
};

// COMPLIANT: Non-member symmetrical operators
TestClass operator-(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
TestClass operator*(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
TestClass operator/(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
TestClass operator%(const TestClass &lhs, const TestClass &rhs); // COMPLIANT

bool operator!=(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
bool operator<(const TestClass &lhs, const TestClass &rhs);  // COMPLIANT
bool operator<=(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
bool operator>=(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
bool operator>(const TestClass &lhs, const TestClass &rhs);  // COMPLIANT

TestClass operator^(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
TestClass operator&(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
TestClass operator|(const TestClass &lhs, const TestClass &rhs); // COMPLIANT

bool operator&&(const TestClass &lhs, const TestClass &rhs); // COMPLIANT
bool operator||(const TestClass &lhs, const TestClass &rhs); // COMPLIANT

// COMPLIANT: Mixed type non-member symmetrical operators
TestClass operator+(const TestClass &lhs, std::int32_t rhs); // COMPLIANT
TestClass operator+(std::int32_t lhs, const TestClass &rhs); // COMPLIANT