#include <cstdint>

/* ========== 1. Fixtures ========== */

// Unscoped, no fixed type
enum Unfixed { U0, U1, U2 };
enum Unfixed2 { V0 = 10, V1, V2 };

// Unscoped, with fixed type
enum Fixed : std::int32_t { F0 = 20, F1, F2 };
enum Fixed2 : std::int32_t { G0 = 30, G1, G2 };

// Scoped enum (defaults to int)
enum class Scoped { S0, S1, S2 };

// Scoped, with fixed type
enum class ScopedFixed : std::int32_t { SF0, SF1, SF2 };

// Unscoped, no fixed type, large values
enum UnfixedLarge { UL0 = 0x7FFFFFFF, UL1 };

/* ========== 2. Arithmetic operators ========== */

void arithmetic() {
  Unfixed u = U0;
  Fixed f = F0;

  u + 1; // NON_COMPLIANT: arithmetic on unfixed unscoped enum
  u - 1; // NON_COMPLIANT: arithmetic on unfixed unscoped enum
  u * 2; // NON_COMPLIANT: arithmetic on unfixed unscoped enum
  u / 2; // NON_COMPLIANT: arithmetic on unfixed unscoped enum
  u % 2; // NON_COMPLIANT: arithmetic on unfixed unscoped enum

  f + 1; // COMPLIANT: fixed underlying type
  f - 1; // COMPLIANT: fixed underlying type
}

/* ========== 3. Bitwise operators ========== */

void bitwise() {
  Unfixed u = U0;
  Fixed f = F0;

  u | U1; // NON_COMPLIANT: bitwise on unfixed unscoped enum
  u & U1; // NON_COMPLIANT: bitwise on unfixed unscoped enum
  u ^ U1; // NON_COMPLIANT: bitwise on unfixed unscoped enum

  f | F1; // COMPLIANT: fixed underlying type
  f & F1; // COMPLIANT: fixed underlying type
}

/* ========== 4. Shift operators ========== */

void shift() {
  Unfixed u = U0;
  Fixed f = F0;

  u << 1; // NON_COMPLIANT: shift on unfixed unscoped enum
  u >> 1; // NON_COMPLIANT: shift on unfixed unscoped enum

  f << 1; // COMPLIANT: fixed underlying type
  f >> 1; // COMPLIANT: fixed underlying type
}

/* ========== 5. Logical operators ========== */

void logical() {
  Unfixed u = U0;
  Fixed f = F0;

  u &&U1;  // NON_COMPLIANT: logical on unfixed unscoped enum
  u || U1; // NON_COMPLIANT: logical on unfixed unscoped enum

  f &&F1; // COMPLIANT: fixed underlying type
}

/* ========== 6. Compound assignment operators ========== */

void compound_assignment() {
  Unfixed u = U0;
  Fixed f = F0;
  int i = 0;

  i += u;  // NON_COMPLIANT: compound assignment with unfixed unscoped enum
  i -= u;  // NON_COMPLIANT: compound assignment with unfixed unscoped enum
  i *= u;  // NON_COMPLIANT: compound assignment with unfixed unscoped enum
  i /= u;  // NON_COMPLIANT: compound assignment with unfixed unscoped enum
  i |= u;  // NON_COMPLIANT: compound assignment with unfixed unscoped enum
  i &= u;  // NON_COMPLIANT: compound assignment with unfixed unscoped enum
  i ^= u;  // NON_COMPLIANT: compound assignment with unfixed unscoped enum
  i <<= u; // NON_COMPLIANT: compound assignment with unfixed unscoped enum
  i >>= u; // NON_COMPLIANT: compound assignment with unfixed unscoped enum

  i += f; // COMPLIANT: fixed underlying type
  i |= f; // COMPLIANT: fixed underlying type
}

/* ========== 7. Relational and equality operators ========== */

void relational() {
  Unfixed u = U0;
  Unfixed u2 = U1;
  Fixed f = F0;
  Fixed f2 = F1;

  u == u2; // COMPLIANT: same enum type
  u != u2; // COMPLIANT: same enum type
  u < u2;  // COMPLIANT: same enum type
  u > u2;  // COMPLIANT: same enum type
  u <= u2; // COMPLIANT: same enum type
  u >= u2; // COMPLIANT: same enum type

  u == 0; // NON_COMPLIANT: comparing unfixed enum to int
  u < 5;  // NON_COMPLIANT: comparing unfixed enum to int
  u != 1; // NON_COMPLIANT: comparing unfixed enum to int

  f == 0; // COMPLIANT: fixed underlying type
  f < 5;  // COMPLIANT: fixed underlying type
}

/* ========== 8. Assignment ========== */

void assignment() {
  Unfixed u = U0;
  Fixed f = F0;

  std::int32_t i32;
  std::int8_t i8;
  std::int64_t i64;

  i32 = u; // COMPLIANT: std::int32_t large enough
  i64 = u; // COMPLIANT: std::int64_t large enough
  i8 = u;  // NON_COMPLIANT: std::int8_t might not hold all values

  i32 = f; // COMPLIANT: fixed underlying type
  i8 = f;  // COMPLIANT: fixed underlying type

  Unfixed u2;
  u2 = u; // COMPLIANT: same enum type
}

/* ========== 9. Switch statements ========== */

void switch_statements() {
  Unfixed u = U0;
  Fixed f = F0;

  switch (u) {
  case U0:
    break;
  case U1:
    break;
  case U2:
    break; // COMPLIANT: all cases are enumerators of same type
  }

  switch (u) {
  case U0:
    break;
  case 5:
    break; // NON_COMPLIANT: mixed enumerator and integer literal
  }

  switch (u) {
  case U0:
    break;
  case F0:
    break; // NON_COMPLIANT: mixed enumerators from different enums
  }

  switch (f) {
  case F0:
    break;
  case 5:
    break; // COMPLIANT: fixed underlying type
  }
}

/* ========== 10. static_cast FROM unfixed enum ========== */

void static_cast_from_unfixed() {
  Unfixed u = U0;

  // Target is same enumeration type
  static_cast<Unfixed>(u); // COMPLIANT: same enum type

  // Target is integer type large enough
  static_cast<int>(u);          // COMPLIANT: int guaranteed large enough
  static_cast<long>(u);         // COMPLIANT: long >= int
  static_cast<std::int64_t>(u); // COMPLIANT: std::int64_t >= int
  static_cast<unsigned int>(u); // COMPLIANT: unsigned int large enough

  // Target is integer type that might not be large enough
  static_cast<std::int8_t>(
      u); // NON_COMPLIANT: std::int8_t might not hold all values
  static_cast<std::uint8_t>(
      u); // NON_COMPLIANT: std::uint8_t might not hold all values
  static_cast<std::int16_t>(
      u);               // NON_COMPLIANT: std::int16_t might not hold all values
  static_cast<char>(u); // NON_COMPLIANT: char might not hold all values

  // Target is different enumeration type
  static_cast<Unfixed2>(u); // NON_COMPLIANT: different enum type
  static_cast<Fixed>(u);    // NON_COMPLIANT: different enum type
  static_cast<Scoped>(u);   // NON_COMPLIANT: different enum type
}

/* ========== 11. static_cast FROM fixed enum ========== */

void static_cast_from_fixed() {
  Fixed f = F0;

  // All compliant because source has fixed underlying type
  static_cast<Fixed>(f);       // COMPLIANT: fixed underlying type
  static_cast<int>(f);         // COMPLIANT: fixed underlying type
  static_cast<std::int8_t>(f); // COMPLIANT: fixed underlying type
  static_cast<Unfixed>(f); // NON_COMPLIANT: target is unfixed enum (TO rule)
}

/* ========== 12. static_cast TO unfixed enum ========== */

void static_cast_to_unfixed() {
  int i = 0;
  std::int8_t i8 = 0;
  std::int64_t i64 = 0;

  // Any static_cast from non-enum to unfixed enum is non-compliant
  static_cast<Unfixed>(0);   // NON_COMPLIANT: unfixed enum as target
  static_cast<Unfixed>(i);   // NON_COMPLIANT: unfixed enum as target
  static_cast<Unfixed>(i8);  // NON_COMPLIANT: unfixed enum as target
  static_cast<Unfixed>(i64); // NON_COMPLIANT: unfixed enum as target
}

/* ========== 13. static_cast TO fixed enum ========== */

void static_cast_to_fixed() {
  int i = 0;
  Unfixed u = U0;

  // Fixed enum as target is compliant (for the TO rule)
  static_cast<Fixed>(0);  // COMPLIANT: fixed enum as target
  static_cast<Fixed>(i);  // COMPLIANT: fixed enum as target
  static_cast<Fixed>(F0); // COMPLIANT: fixed enum as target
  static_cast<Fixed>(u);  // NON_COMPLIANT: source is unfixed enum, target is
                          // different type (FROM rule)
}

/* ========== 14. static_cast TO scoped enum ========== */

void static_cast_to_scoped() {
  int i = 0;
  Unfixed u = U0;

  // Scoped enums have fixed underlying type (defaults to int)
  static_cast<Scoped>(0); // COMPLIANT: scoped enum has fixed type
  static_cast<Scoped>(i); // COMPLIANT: scoped enum has fixed type
  static_cast<Scoped>(u); // NON_COMPLIANT: source is unfixed enum, target is
                          // different type (FROM rule)
}

/* ========== 15. static_cast FROM scoped enum ========== */

void static_cast_from_scoped() {
  Scoped s = Scoped::S0;

  // Scoped enums have fixed underlying type
  static_cast<int>(s);         // COMPLIANT: scoped enum has fixed type
  static_cast<std::int8_t>(s); // COMPLIANT: scoped enum has fixed type
  static_cast<Scoped>(s);      // COMPLIANT: same type, fixed
  static_cast<Unfixed>(s); // NON_COMPLIANT: target is unfixed enum (TO rule)
}

/* ========== 16. Cross-enum relational operators ========== */

void cross_enum_relational() {
  Unfixed u = U0;
  Fixed f = F0;
  Scoped s = Scoped::S0;

  // Unfixed vs Fixed (both unscoped, different types)
  u == f; // NON_COMPLIANT: different enum types, unfixed operand
  u < f;  // NON_COMPLIANT: different enum types, unfixed operand
  u != f; // NON_COMPLIANT: different enum types, unfixed operand

  // Fixed vs Fixed (same type)
  f == F1; // COMPLIANT: same enum type, fixed

  // Unfixed vs Scoped - with cast
  u == static_cast<int>(s); // NON_COMPLIANT: unfixed enum compared to int

  static_cast<int>(u) == static_cast<int>(s); // COMPLIANT: comparing ints

  // Fixed vs Scoped - with cast
  f == static_cast<std::int32_t>(s); // COMPLIANT: fixed enum compared to int
}

/* ========== 17. Cross-enum arithmetic operators ========== */

void cross_enum_arithmetic() {
  Unfixed u = U0;
  Fixed f = F0;
  Scoped s = Scoped::S0;

  u + f; // NON_COMPLIANT: arithmetic with unfixed operand
  f + u; // NON_COMPLIANT: arithmetic with unfixed operand
  u - f; // NON_COMPLIANT: arithmetic with unfixed operand

  f + static_cast<std::int32_t>(s); // COMPLIANT: fixed enum + int

  u + U1; // NON_COMPLIANT: arithmetic on unfixed
}

/* ========== 18. Cross-enum bitwise operators ========== */

void cross_enum_bitwise() {
  Unfixed u = U0;
  Fixed f = F0;

  u | f; // NON_COMPLIANT: bitwise with unfixed operand
  u & f; // NON_COMPLIANT: bitwise with unfixed operand
  u ^ f; // NON_COMPLIANT: bitwise with unfixed operand
  f | u; // NON_COMPLIANT: bitwise with unfixed operand

  f | F1; // COMPLIANT: both fixed, same type
}

/* ========== 19. Two different unfixed enums ========== */

void two_unfixed() {
  Unfixed u = U0;
  Unfixed2 v = V0;

  u == v; // NON_COMPLIANT: different enum types, both unfixed
  u < v;  // NON_COMPLIANT: different enum types, both unfixed
  u + v;  // NON_COMPLIANT: arithmetic on unfixed
  u | v;  // NON_COMPLIANT: bitwise on unfixed

  switch (u) {
  case U0:
    break;
  case V0:
    break; // NON_COMPLIANT: case from different unfixed enum
  }
}

/* ========== 20. Two different fixed enums ========== */

void two_fixed() {
  Fixed f = F0;
  Fixed2 g = G0;

  f == g; // COMPLIANT: both have fixed underlying type
  f < g;  // COMPLIANT: both have fixed underlying type
  f + g;  // COMPLIANT: both have fixed underlying type
  f | g;  // COMPLIANT: both have fixed underlying type

  switch (f) {
  case F0:
    break;
  case G0:
    break; // COMPLIANT: both have fixed underlying type
  }
}

/* ========== 21. Mixed fixed and unfixed ========== */

void mixed_fixed_unfixed() {
  Unfixed u = U0;
  Fixed f = F0;
  Unfixed2 v = V0;
  Fixed2 g = G0;

  // The presence of ANY unfixed operand makes it non-compliant
  u + f; // NON_COMPLIANT: u is unfixed
  f + u; // NON_COMPLIANT: u is unfixed
  u + g; // NON_COMPLIANT: u is unfixed
  v + f; // NON_COMPLIANT: v is unfixed
  v + g; // NON_COMPLIANT: v is unfixed

  u == f; // NON_COMPLIANT: u is unfixed, different types
  f == u; // NON_COMPLIANT: u is unfixed, different types

  f + g;  // COMPLIANT: both fixed
  f == g; // COMPLIANT: both fixed
}

/* ========== 22. Scoped enum operations ========== */

void scoped_enum_ops() {
  Scoped s = Scoped::S0;

  // These don't compile without explicit cast, so they're safe by design
  // s + 1;         // Would not compile
  // s == 0;        // Would not compile

  static_cast<int>(s);    // COMPLIANT: scoped enum
  static_cast<Scoped>(1); // COMPLIANT: scoped enum
}

/* ========== 23. Member unfixed enum ========== */

class C1 {
  enum MemberUnfixed { M0, M1, M2 };

  void member_ops() {
    MemberUnfixed m = M0;

    m + 1;   // NON_COMPLIANT: arithmetic on unfixed enum (even if member)
    m == 0;  // NON_COMPLIANT: comparing unfixed enum to int (even if member)
    m == M1; // COMPLIANT: same enum type
  }
};

int main() { return 0; }