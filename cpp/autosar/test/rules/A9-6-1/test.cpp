#include <cstdint>

typedef std::int8_t MYINT;

enum E0 { E01, E02 };

enum class E1 { E11, E12 };

enum class E2 : std::int8_t { E21, E22 };

enum class E3 : char { E31, E32 };

enum E4 : char { E41, E42 };

enum E5 : std::int8_t { E51, E52 };

/**
 * @HardwareOrProtocolInterface
 */
class HW_A { // NON_COMPLIANT
public:
  virtual void a() {}
};

/**
 * @HardwareOrProtocolInterface
 */
class HW_A1 : HW_A { // NON_COMPLIANT
public:
  std::int8_t a;
}; // NON-COMPLIANT - non-POD class with compliant types.

/**
 * @HardwareOrProtocolInterface
 */
class HW_B {};

class B {};

class C {
public:
  std::int8_t c;
};

class D {
public:
  char c;
};

/**
 * @HardwareOrProtocolInterface
 */
class HW_B1 : HW_B {
public:
  std::int8_t a; // COMPLIANT
};

/**
 * @HardwareOrProtocolInterface
 */
class HW_B2 : HW_B {
public:
  std::int8_t a1; // COMPLIANT
  MYINT a2;       // COMPLIANT

  char b1;     // NON-COMPLIANT
  char c1 : 2; // NON-COMPLIANT

  E0 e0; // NON-COMPLIANT
  E1 e1; // NON-COMPLIANT
  E2 e2; // COMPLIANT
  E3 e3; // NON-COMPLIANT
  E4 e4; // NON-COMPLIANT
  E5 e5; // COMPLIANT
  C c2;  // COMPLIANT
  D d1;  // NON-COMPLIANT
};

// This class will implicitly get flagged
// as a hardware interface class because it uses bitfields.
class B2 : B {
public:
  std::int8_t a; // COMPLIANT
  char b;        // NON-COMPLIANT
  char c : 2;    // NON-COMPLIANT
};
