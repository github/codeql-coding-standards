#include <fstream>
#include <string>

void f(int &i) { // NON_COMPLIANT - read without write
  int &j = i;
}
void f1(std::string &str) { // NON_COMPLIANT - replacement without reading
  str = "replacement";
}
void f2(std::string &str) { // COMPLIANT
  str += "suffix";
}

void f3(int &i) { // COMPLIANT - modular case
  f(i);
}

void f4(int &i) { // NON_COMPLIANT - replace without reading
  int x = 10;
  i = x;
}

void f4a(const int &i) { // COMPLIANT
}

void f5a(int &i) { // NON_COMPLIANT - f4a has a const signature and cannot
                   // satisfy the contract
  f4a(i);
}

void f5(int &i) { // COMPLIANT - modular case
  f4(i);
}

class A {
public:
  int m;
};
void f6(A &a) { // COMPLIANT
  a.m = 0;
  int l = a.m;
}
void f7(A &a) { // NON_COMPLIANT
  a = A();
}

void f8(int i) { // COMPLIANT
  i += 1;
}

template <typename T> void f9(T &x) { // COMPLIANT
  // not instantiated, therefore cannot see accesses within
  x.~T();
}

class B {
  int _i;

public:
  B(int &b) : _i(b) {} // COMPLIANT
};

inline std::ostream &
operator<<(std::ostream &ostr,
           const A &a) { // COMPLIANT ignore bc operator call means param cannot
                         // have been const anyways
  ostr << a.m;
  return ostr;
}

void f10(A &a) { // COMPLIANT
  f6(a);
}

void f11_external(A &a);

void f11(A &a) {
  f11_external(a); // COMPLIANT
}

void f12(A &a) { // COMPLIANT
  f11(a);
}

void f13(int &a) { // NON_COMPLIANT - only reads
  int i = a;
}

void f13a(int &a) { // NON_COMPLIANT - replaces without reading
  a = 1;
}

void f14(A &a) {} // NON_COMPLIANT -- base case
void f14a(A &a);  // COMPLIANT     -- base case

void f15(A &a) { // COMPLIANT - modular case
  f14(a);
}

void f15a(A &a) { // COMPLIANT - modular case
  f14a(a);
}
void f16(A &a) { // COMPLIANT - modular case
  f15(a);
}

void f16a(A &a) { // COMPLIANT - modular case
  f15a(a);
}

void f17(A &a) { // NON_COMPLIANT - replaces without reading
  A aa;
  a = aa;
}

void f18(A &a) { // COMPLIANT
  A aa;
  int i = a.m;
  a = aa;
}

void f18aa(
    A &a) { // NON_COMPLIANT -- when corrected, f18a becomes "path" compliant
  A aa;
  a = aa;
}

void f18a(A &a) { // COMPLIANT - modular compliance
  A aa;
  int i = a.m;
  f18aa(a);
}

void f19(A &a) { // COMPLIANT - order is ignored
  A aa;
  a = aa;
  int i = a.m;
}
