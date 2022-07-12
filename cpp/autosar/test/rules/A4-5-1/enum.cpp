enum Street { Road, Lane, Avenue, Boulevard, Place };

Street operator&=(Street left, Street right) { return left; }
Street operator^=(Street left, int) { return left; }
Street operator>>=(Street left, int) { return left; }
Street operator<<=(Street left, int) { return left; }

void test_enum() {
  int arr[Street::Place] = {};
  Street e = Lane;     // COMPLIANT
  Lane == Lane;        // COMPLIANT
  Place != Place;      // COMPLIANT
  Road < Lane;         // COMPLIANT
  Avenue <= Avenue;    // COMPLIANT
  Place > Road;        // COMPLIANT
  Boulevard >= Avenue; // COMPLIANT
  Place &Avenue;       // COMPLIANT
  arr[Road] = 1;       // COMPLIANT

  // arithmetic
  Avenue + Place; // NON_COMPLIANT
  Place - Place;  // NON_COMPLIANT
  -Avenue;        // NON_COMPLIANT
  Road % 0;       // NON_COMPLIANT
  Avenue / 1;     // NON_COMPLIANT
  Boulevard * 2;  // NON_COMPLIANT

  // logical
  Lane &&Road;   // NON_COMPLIANT
  Place || Lane; // NON_COMPLIANT
  !Road;         // NON_COMPLIANT

  // bitwise
  Boulevard | Boulevard; // NON_COMPLIANT
  ~Lane;                 // NON_COMPLIANT
  Place ^ Road;          // NON_COMPLIANT
  Road >> 1;             // NON_COMPLIANT
  Road << 1;             // NON_COMPLIANT
  Avenue &= Place;       // NON_COMPLIANT
  Road ^= Road;          // NON_COMPLIANT
  Road >>= Road;         // NON_COMPLIANT
  Road <<= Road;         // NON_COMPLIANT
}

void test_enum_var() {
  Street a = Lane; // COMPLIANT
  Street b = Road; // COMPLIANT
  a == b;          // COMPLIANT
  a != b;          // COMPLIANT
  a < b;           // COMPLIANT
  a <= b;          // COMPLIANT
  a > b;           // COMPLIANT
  a >= b;          // COMPLIANT
  a &b;            // COMPLIANT

  // arithmetic
  a + a; // NON_COMPLIANT
  a - a; // NON_COMPLIANT
  -a;    // NON_COMPLIANT
  a % 0; // NON_COMPLIANT
  a / 1; // NON_COMPLIANT
  a * 2; // NON_COMPLIANT

  // logical
  a &&b;  // NON_COMPLIANT
  a || b; // NON_COMPLIANT
  !b;     // NON_COMPLIANT

  // bitwise
  a | b;   // NON_COMPLIANT
  ~a;      // NON_COMPLIANT
  a ^ b;   // NON_COMPLIANT
  a >> 1;  // NON_COMPLIANT
  a << 1;  // NON_COMPLIANT
  a &= b;  // NON_COMPLIANT
  a ^= 1;  // NON_COMPLIANT
  a >>= 1; // NON_COMPLIANT
  a <<= 1; // NON_COMPLIANT
}