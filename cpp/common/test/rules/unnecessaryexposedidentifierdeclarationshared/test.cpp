extern void f1(int i);
extern int g1; // COMPLIANT
extern int g2; // NON_COMPLIANT; single use of a global variable
bool f2() { return g1 == 1; }
void f3() {
  int j = g1; // NON_COMPLIANT
  if (f2()) {
    int k; // COMPLIANT
    f1(j);
    f1(k);
  }
}

void f4() {
  int j = g1; // COMPLIANT; value of g1 changed between
              // definition and use
  g1 = 1;
  if (f2()) {
    f1(j);
  }
}

void f5() {
  int j = g1; // COMPLIANT; shouldn't be moved inside loop
  while (true) {
    int i = g1++;
    while (f2()) {
      i += j;
    }

    if (i % 2)
      break;
  }
}

void f6() {
  int j = g1; // COMPLIANT; can't moved into smaller scope
#ifdef FOO
  if (g1) {
    g1 = j + 1;
  }
#else
  if (g1) {
    g1 = j + 2;
  }
#endif
}

void f7() {
  int j = g1; // COMPLIANT; potentially stores previous value of
              // g1 so moving this would be incorrect.
  f1(1);      // f1 may change the value of g1
  if (f2()) {
    f1(j);
  }
}

void f8() { int i = g2; }

void f9() {
  int i; // NON_COMPLIANT

  if (f2()) {
    if (f2()) {
      i++;
    } else {
      i--;
    }
  }
}

struct S1 { // NON_COMPLIANT
  int i;
};

void f10() { S1 l1{}; }

void f11() {
  struct S2 { // COMPLIANT
    int i;
  } l1{};
}

struct S3 {
  int i;
};

template <typename T> int f12(T p);
template <> int f12(S3 p) { return p.i; }

struct S4 { // NON_COMPLIANT; single use in function f13
  int i;
};

template <typename T> class C1 { // COMPLIANT; used in both f13 and f14
private:
  T m1;
};

void f13() { C1<S4> l1; }
void f14() { C1<int> l1; }

void f15() {
  int i; // COMPLIANT

  if (i == 0) {
    i++;
  }
}

namespace ns1 {
int i; // NON_COMPLIANT
namespace ns2 {
int j = i + 1;
void f1() { i++; }
} // namespace ns2
} // namespace ns1

void f16() {
  for (int i = 0; i < 10; i++) {
    int j = i + 1; // NON_COMPLIANT[FALSE_NEGATIVE]; we are not consider
                   // candidates inside loops.
    try {
      j++;
    } catch (...) {
    }
  }
}

void f17() {
  int i; // COMPLIANT
  int *ptr;
  {
    // Moving the declaration of i into the reduced scope will result in a
    // dangling pointer
    ptr = &i;
  }
  *ptr = 1;
}