#include <iostream>

class C1 {
public:
  C1(unsigned long long p1) : m1(p1) {}

private:
  unsigned long long m1;
};
C1 operator"" _uds1(unsigned long long p1) { return C1(p1); } // COMPLIANT

int g1 = 0;

class C2 {
public:
  C2(unsigned long long p1) : m1(p1) {}

private:
  unsigned long long m1;
};
C2 operator"" _uds2(unsigned long long p1) {
  g1++; // NON_COMPLIANT - exhibits side effect
  return C2(p1);
}

static void f1(int p1) {
  static int l1 = 0;
  l1 += p1;
}

class C3 {
public:
  C3(unsigned long long p1) : m1(p1) {}

private:
  unsigned long long m1;
};
C3 operator"" _uds3(unsigned long long p1) {
  f1(p1); // NON_COMPLIANT - function f1 exhibits side effect
  return C3(p1);
}

void operator"" _uds4(const char *p1) {
  std::cout << p1; // NON_COMPLIANT - exhibits side effect
}

double operator"" _uds5(unsigned long long p1) {
  return 0.0; // NON_COMPLIANT - not converting passed parameter
}