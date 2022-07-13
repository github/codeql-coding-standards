#include <cstdlib>
#include <string>

class A {
public:
  A();
  A(int i) { _i = i; }
  A operator=(A other) { return other; }
  int _i;
};

struct D {
private:
  virtual void a() {}
};

struct S {
  bool on;
  bool off;
  bool quiet;
  int count;
};

void test() {
  A a(1), b(2);
  struct D d1, d2;
  struct S s1, s2, *s3;

  a = b;                             // COMPLIANT
  std::memset(&s1, 0, sizeof(S));    // COMPLIANT
  std::memcpy(&s1, &s2, 1);          // COMPLIANT
  std::memmove(&s1, &s2, sizeof(S)); // COMPLIANT
  free(s3);                          // COMPLIANT

  std::memset(&a, 0, sizeof(A));   // NON_COMPLIANT
  std::memcpy(&a, &b, 1);          // NON_COMPLIANT
  std::memmove(&a, &b, sizeof(A)); // NON_COMPLIANT
  free(&a);                        // NON_COMPLIANT

  std::memset(&d1, 0, sizeof(D));    // NON_COMPLIANT
  std::memcpy(&d1, &d2, 1);          // NON_COMPLIANT
  std::memmove(&d1, &d2, sizeof(D)); // NON_COMPLIANT
  free(&d1);                         // NON_COMPLIANT
}