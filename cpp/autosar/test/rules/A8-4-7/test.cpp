#include <cstdint>
#include <string>

void f1(std::uint8_t f1a) {}  // COMPLIANT
void f2(std::uint16_t f2a) {} // COMPLIANT
void f3(std::uint32_t f3a) {} // COMPLIANT
void f4(std::uint64_t f4a) {} // COMPLIANT

struct S1 {
  std::uint32_t s1a;
  std::uint32_t s1b;
};

struct S2 {
  std::uint64_t s2a;
  std::uint64_t s2b;
  std::uint64_t s3c;
};

void f5(const S1 &f5a) {}   // NON_COMPLIANT (S1 is a trivial size)
void f6(S1 f6a) {}          // COMPLIANT (S1 is a trivial size)
void f7(const S2 &f7a) {}   // COMPLIANT (S2 is not a trivial size)
void f8(S2 f8a) {}          // NON_COMPLIANT (S2 is not a trivial size)
void f9(S1 *f9a) {}         // COMPLIANT (S1 is a trivial size but is not const)
void f10(S1 f10a) {}        // COMPLIANT (S1 is a trivial size)
void f11(S2 *f11a) {}       // COMPLIANT (S2 is not a trivial size)
void f12(S2 f12a) {}        // NON_COMPLIANT (S2 is not a trivial size)
void f12(const S1 *f12a) {} // COMPLIANT (S1 is a trivial size)

void test() {
  try {
  } catch (S1 &s) { // COMPLIANT
  }
}
inline S1 Value(size_t n, const char *data) {} // COMPLIANT

struct A {
  int n;
  A(const A &a) : n(a.n) {} // COMPLIANT user-defined copy ctor
};
