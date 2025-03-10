// NON-COMPLIANT
#define M1 _Generic(1, default : 1);
// COMPLIANT
#define M2 _Generic(1, int : 1);
// COMPLIANT
#define M3 _Generic(1, int : 1, default : 1);
// COMPLIANT
#define M4 _Generic(1, int : 1, long : 1);

void f() {
  // Invalid generics:
  // _Generic(1);
  // _Generic(1, void: 1);
  _Generic(1, default : 1);          // NON-COMPLIANT
  _Generic(1, int : 1);              // COMPLIANT
  _Generic(1, int : 1, default : 1); // COMPLIANT
  _Generic(1, int : 1, long : 1);    // COMPLIANT

  M1;
  M2;
  M3;
  M4;
}