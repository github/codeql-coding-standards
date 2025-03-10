#define M1(X) _Generic((X), int : 1)

// NON_COMPLIANT:
#define M2(X) _Generic((X)++, int : 1)

// NON_COMPLIANT:
#define M3(X) _Generic(l1++, int : (X))

// COMPLIANT:
#define M3_WRAPPER(X) M3(X)

#define M4(X) _Generic((X)(), int : 1)

void f1() {
  int l1;

  _Generic(1, int : 1);  // COMPLIANT
  M1(1);                 // COMPLIANT
  _Generic(l1, int : 1); // COMPLIANT
  M1(l1);                // COMPLIANT

  _Generic(l1++,
           int : 1); // COMPLIANT: side effect is not from a macro argument.
  M1(l1++);          // COMPLIANT
  M2(l1);            // NON-COMPLIANT: at macro definition
  M3(1);             // NON-COMPLIANT: at macro definition
  M3_WRAPPER(1);     // NON-COMPLIANT: at definition of M3
}

int g1;
int pure() { return g1; }

int impure() { return g1++; }

void f2() {
  M1(pure());   // COMPLIANT
  M1(impure()); // COMPLIANT
  M4(pure);     // COMPLIANT
  M4(impure);   // NON_COMPLIANT[False negative]
}

#define M5(X)                                                                  \
  static volatile l##X;                                                        \
  _Generic(l##X, int : 1)

void f3() {
  M5(a); // NON-COMPLIANT
  M5(b); // NON-COMPLIANT
}