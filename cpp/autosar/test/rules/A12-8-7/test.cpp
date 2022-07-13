#include <cstdint>
class A {

public:
  A() = default;
  A &operator=(std::int16_t i) { return *this; };   // NON_COMPLIANT
  A &operator+=(std::int16_t i) { return *this; };  // NON_COMPLIANT
  A &operator-=(std::int16_t i) { return *this; };  // NON_COMPLIANT
  A &operator*=(std::int16_t i) { return *this; };  // NON_COMPLIANT
  A &operator/=(std::int16_t i) { return *this; };  // NON_COMPLIANT
  A &operator%=(std::int16_t i) { return *this; };  // NON_COMPLIANT
  A &operator^=(std::int16_t i) { return *this; };  // NON_COMPLIANT
  A &operator&=(std::int16_t i) { return *this; };  // NON_COMPLIANT
  A &operator|=(std::int16_t i) { return *this; };  // NON_COMPLIANT
  A &operator>>=(std::int16_t i) { return *this; }; // NON_COMPLIANT
};

class B {
public:
  B() = default;
  B &operator=(std::int16_t i) & { return *this; };   // COMPLIANT
  B &operator+=(std::int16_t i) & { return *this; };  // COMPLIANT
  B &operator-=(std::int16_t i) & { return *this; };  // COMPLIANT
  B &operator*=(std::int16_t i) & { return *this; };  // COMPLIANT
  B &operator/=(std::int16_t i) & { return *this; };  // COMPLIANT
  B &operator%=(std::int16_t i) & { return *this; };  // COMPLIANT
  B &operator^=(std::int16_t i) & { return *this; };  // COMPLIANT
  B &operator&=(std::int16_t i) & { return *this; };  // COMPLIANT
  B &operator|=(std::int16_t i) & { return *this; };  // COMPLIANT
  B &operator>>=(std::int16_t i) & { return *this; }; // COMPLIANT
};
