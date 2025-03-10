// NON_COMPLIANT:
#define M1 _Generic(1, int : 1)
// NON_COMPLIANT:
#define M2(X) _Generic(1, int : X)
// COMPLIANT:
#define M3(X) _Generic((X), int : 1)
// COMPLIANT:
#define M4(X) _Generic((X), int : 1)
// COMPLIANT:
#define M5(X) _Generic((X + X), int : 1)
int f1(int a, int b);
// COMPLIANT:
#define M6(X) _Generic(f(1, (X)), int : 1)
#define M7(X) 1 + _Generic((X), int : 1)
// COMPLIANT:
#define M8(X) g(_Generic((X), int : 1))
// NON_COMPLIANT:
#define M9(X) g(_Generic((Y), int : 1))

void f2() {
  _Generic(1, int : 1); // NON_COMPLIANT
  M1;                   // NON_COMPLIANT
  M2(1);                // NON_COMPLIANT
  M3(1);                // COMPLIANT
}
