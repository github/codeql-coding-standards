#include <cstdint>

// Test user-defined operators - always non-extensible
struct UserDefinedOperators {
  UserDefinedOperators(std::int32_t l1) {}

  // Binary operators
  UserDefinedOperators operator+(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator-(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator*(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator/(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator%(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator&(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator|(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator^(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator<<(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }
  UserDefinedOperators operator>>(std::int32_t l1) const {
    return UserDefinedOperators{0};
  }

  // Comparison operators
  bool operator==(std::int32_t l1) const { return true; }
  bool operator!=(std::int32_t l1) const { return false; }
  bool operator<(std::int32_t l1) const { return false; }
  bool operator<=(std::int32_t l1) const { return false; }
  bool operator>(std::int32_t l1) const { return false; }
  bool operator>=(std::int32_t l1) const { return false; }

  // Subscript operator
  std::int32_t operator[](std::int32_t l1) const { return 0; }

  // Function call operator
  std::int32_t operator()(std::int32_t l1) const { return 0; }
  std::int32_t operator()(std::int32_t l1, std::int32_t l2) const { return 0; }

  // Assignment operators
  UserDefinedOperators &operator=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator+=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator-=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator*=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator/=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator%=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator&=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator|=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator^=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator<<=(std::int32_t l1) { return *this; }
  UserDefinedOperators &operator>>=(std::int32_t l1) { return *this; }

  // Increment/decrement operators
  UserDefinedOperators &operator++() { return *this; }
  UserDefinedOperators operator++(int) { return UserDefinedOperators{0}; }
  UserDefinedOperators &operator--() { return *this; }
  UserDefinedOperators operator--(int) { return UserDefinedOperators{0}; }
};

// Global user-defined operators
UserDefinedOperators operator+(std::int32_t l1,
                               const UserDefinedOperators &l2) {
  return UserDefinedOperators{0};
}

UserDefinedOperators operator-(std::int32_t l1,
                               const UserDefinedOperators &l2) {
  return UserDefinedOperators{0};
}

bool operator==(std::int32_t l1, const UserDefinedOperators &l2) {
  return true;
}

void test_user_defined_operators() {
  UserDefinedOperators l1{42};
  std::int32_t l2 = 10;
  std::int16_t l3 = 5;
  std::int64_t l4 = 100;
  std::uint32_t l5 = 20;

  // Member operators - non-extensible, exact type match required
  l1 + l2; // COMPLIANT - exact type match
  l1 + l3; // COMPLIANT - widening conversion is allowed
  l1 + l4; // NON_COMPLIANT - different type
  l1 + l5; // NON_COMPLIANT - different signedness

  l1 - l2; // COMPLIANT - exact type match
  l1 - l3; // COMPLIANT - widening conversion is allowed
  l1 - l4; // NON_COMPLIANT - different type
  l1 - l5; // NON_COMPLIANT - different signedness

  l1 *l2; // COMPLIANT - exact type match
  l1 *l3; // COMPLIANT - widening conversion is allowed
  l1 *l4; // NON_COMPLIANT - different type
  l1 *l5; // NON_COMPLIANT - different signedness

  l1 / l2; // COMPLIANT - exact type match
  l1 / l3; // COMPLIANT - widening conversion is allowed
  l1 / l4; // NON_COMPLIANT - different type
  l1 / l5; // NON_COMPLIANT - different signedness

  l1 % l2; // COMPLIANT - exact type match
  l1 % l3; // COMPLIANT - widening conversion is allowed
  l1 % l4; // NON_COMPLIANT - different type
  l1 % l5; // NON_COMPLIANT - different signedness

  l1 &l2; // COMPLIANT - exact type match
  l1 &l3; // COMPLIANT - widening conversion is allowed
  l1 &l4; // NON_COMPLIANT - different type
  l1 &l5; // NON_COMPLIANT - different signedness

  l1 | l2; // COMPLIANT - exact type match
  l1 | l3; // COMPLIANT - widening conversion is allowed
  l1 | l4; // NON_COMPLIANT - different type
  l1 | l5; // NON_COMPLIANT - different signedness

  l1 ^ l2; // COMPLIANT - exact type match
  l1 ^ l3; // COMPLIANT - widening conversion is allowed
  l1 ^ l4; // NON_COMPLIANT - different type
  l1 ^ l5; // NON_COMPLIANT - different signedness

  l1 << l2; // COMPLIANT - exact type match
  l1 << l3; // COMPLIANT - widening conversion is allowed
  l1 << l4; // NON_COMPLIANT - different type
  l1 << l5; // NON_COMPLIANT - different signedness

  l1 >> l2; // COMPLIANT - exact type match
  l1 >> l3; // COMPLIANT - widening conversion is allowed
  l1 >> l4; // NON_COMPLIANT - different type
  l1 >> l5; // NON_COMPLIANT - different signedness

  // Comparison operators
  l1 == l2; // COMPLIANT - exact type match
  l1 == l3; // COMPLIANT - widening conversion is allowed
  l1 == l4; // NON_COMPLIANT - different type
  l1 == l5; // NON_COMPLIANT - different signedness

  l1 != l2; // COMPLIANT - exact type match
  l1 != l3; // COMPLIANT - widening conversion is allowed
  l1 != l4; // NON_COMPLIANT - different type
  l1 != l5; // NON_COMPLIANT - different signedness

  l1 < l2; // COMPLIANT - exact type match
  l1 < l3; // COMPLIANT - widening conversion is allowed
  l1 < l4; // NON_COMPLIANT - different type
  l1 < l5; // NON_COMPLIANT - different signedness

  l1 <= l2; // COMPLIANT - exact type match
  l1 <= l3; // COMPLIANT - widening conversion is allowed
  l1 <= l4; // NON_COMPLIANT - different type
  l1 <= l5; // NON_COMPLIANT

  l1 > l2; // COMPLIANT - exact type match
  l1 > l3; // COMPLIANT - widening conversion is allowed
  l1 > l4; // NON_COMPLIANT
  l1 > l5; // NON_COMPLIANT - different signedness

  l1 >= l2; // COMPLIANT - exact type match
  l1 >= l3; // COMPLIANT - widening conversion is allowed
  l1 >= l4; // NON_COMPLIANT
  l1 >= l5; // NON_COMPLIANT - different signedness

  // Subscript operator
  l1[l2]; // COMPLIANT - exact type match
  l1[l3]; // COMPLIANT - widening conversion is allowed
  l1[l4]; // NON_COMPLIANT - different type
  l1[l5]; // NON_COMPLIANT - different signedness

  // Function call operator
  l1(l2);     // COMPLIANT - exact type match
  l1(l3);     // COMPLIANT - widening conversion is allowed
  l1(l4);     // NON_COMPLIANT - different type
  l1(l5);     // NON_COMPLIANT - different signedness
  l1(l2, l2); // COMPLIANT - both exact type match
  l1(l2, l4); // NON_COMPLIANT - second parameter different type
  l1(l4, l2); // NON_COMPLIANT - first parameter different type
  l1(l4, l5); // NON_COMPLIANT - both parameters different type

  // The presence of a default copy constructor for UserDefinedOperators means
  // that assignments through operator= must be exact type matches.
  l1 = l2; // COMPLIANT - exact type match
  l1 = l3; // NON_COMPLIANT
  l1 = l4; // NON_COMPLIANT
  l1 = l5; // NON_COMPLIANT

  l1 += l2; // COMPLIANT - exact type match
  l1 += l3; // COMPLIANT - widening conversion is allowed
  l1 += l4; // NON_COMPLIANT - different type
  l1 += l5; // NON_COMPLIANT - different signedness

  l1 -= l2; // COMPLIANT - exact type match
  l1 -= l3; // COMPLIANT - widening conversion is allowed
  l1 -= l4; // NON_COMPLIANT - different type
  l1 -= l5; // NON_COMPLIANT - different signedness

  l1 *= l2; // COMPLIANT - exact type match
  l1 *= l3; // COMPLIANT - widening conversion is allowed
  l1 *= l4; // NON_COMPLIANT - different type
  l1 *= l5; // NON_COMPLIANT - different signedness

  l1 /= l2; // COMPLIANT - exact type match
  l1 /= l3; // COMPLIANT - widening conversion is allowed
  l1 /= l4; // NON_COMPLIANT - different type
  l1 /= l5; // NON_COMPLIANT - different signedness

  l1 %= l2; // COMPLIANT - exact type match
  l1 %= l3; // COMPLIANT - widening conversion is allowed
  l1 %= l4; // NON_COMPLIANT - different type
  l1 %= l5; // NON_COMPLIANT - different signedness

  l1 &= l2; // COMPLIANT - exact type match
  l1 &= l3; // COMPLIANT - widening conversion is allowed
  l1 &= l4; // NON_COMPLIANT - different type
  l1 &= l5; // NON_COMPLIANT - different signedness

  l1 |= l2; // COMPLIANT - exact type match
  l1 |= l3; // COMPLIANT - widening conversion is allowed
  l1 |= l4; // NON_COMPLIANT - different type
  l1 |= l5; // NON_COMPLIANT - different signedness

  l1 ^= l2; // COMPLIANT - exact type match
  l1 ^= l3; // COMPLIANT - widening conversion is allowed
  l1 ^= l4; // NON_COMPLIANT - different type
  l1 ^= l5; // NON_COMPLIANT - different signedness

  l1 <<= l2; // COMPLIANT - exact type match
  l1 <<= l3; // COMPLIANT - widening conversion is allowed
  l1 <<= l4; // NON_COMPLIANT - different type
  l1 <<= l5; // NON_COMPLIANT - different signedness

  l1 >>= l2; // COMPLIANT - exact type match
  l1 >>= l3; // COMPLIANT - widening conversion is allowed
  l1 >>= l4; // NON_COMPLIANT - different type
  l1 >>= l5; // NON_COMPLIANT - different signedness

  // Global operators
  l2 + l1; // COMPLIANT - exact type match
  l3 + l1; // COMPLIANT - widening conversion is allowed
  l4 + l1; // NON_COMPLIANT - different type
  l5 + l1; // NON_COMPLIANT - different signedness

  l2 - l1; // COMPLIANT - exact type match
  l3 - l1; // COMPLIANT - widening conversion is allowed
  l4 - l1; // NON_COMPLIANT - different type
  l5 - l1; // NON_COMPLIANT - different signedness

  l2 == l1; // COMPLIANT - exact type match
  l3 == l1; // COMPLIANT - widening conversion is allowed
  l4 == l1; // NON_COMPLIANT - different type
  l5 == l1; // NON_COMPLIANT - different signedness
}

// Test user-defined operators with constants
void test_user_defined_operators_constants() {
  UserDefinedOperators l1{42};

  // Constants with exact type match
  l1 + 42;    // COMPLIANT
  l1 + 42L;   // COMPLIANT
  l1 + 42LL;  // COMPLIANT
  l1 + 42U;   // COMPLIANT
  l1 + 42.0f; // NON_COMPLIANT - float constant

  l1 == 42;   // COMPLIANT - integer constant is int/int32_t
  l1 == 42L;  // COMPLIANT - long constant
  l1 == 42LL; // COMPLIANT - long long constant
  l1 == 42U;  // COMPLIANT - unsigned constant

  l1[42];   // COMPLIANT - integer constant is int/int32_t
  l1[42L];  // COMPLIANT - long constant
  l1[42LL]; // COMPLIANT - long long constant
  l1[42U];  // COMPLIANT - unsigned constant

  // The presence of a default copy constructor for UserDefinedOperators means
  // that assignments through operator= must be exact type matches.
  l1 = 42;   // COMPLIANT - integer constant is int/int32_t
  l1 = 42L;  // NON_COMPLIANT
  l1 = 42LL; // NON_COMPLIANT
  l1 = 42U;  // NON_COMPLIANT
}