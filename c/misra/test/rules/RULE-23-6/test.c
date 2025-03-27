short l1;
int l2;
long l3;
enum { E1 } l4;

#define M1(X) _Generic((X), int : 1, unsigned int : 1, short : 2, long : 3)
void f1() {
  M1(l1); // COMPLIANT
  M1(l2); // COMPLIANT
  M1(l3); // COMPLIANT
  M1(l4); // NON-COMPLIANT

  M1(1);                  // COMPLIANT
  M1(1u);                 // COMPLIANT
  M1(l1 + l1);            // NON-COMPLIANT
  M1((int)(l1 + l1));     // COMPLIANT
  M1('c');                // NON-COMPLIANT[false negative]
  _Generic('c', int : 1); // NON-COMPLIANT
  _Generic(_Generic(0, default : l1 + l1), default : 1); // NON-COMPLIANT
  _Generic(((short)_Generic(0, default : (l1 + l1))), default : 1); // COMPLIANT
}

void f2() {
  // Edge case: lvalue conversion of a const struct yields an implicit
  // conversion to a non-const struct which is ignored by EssentialTypes.qll,
  // meaning the essential type does not match the static type. However, we
  // shouldn't report an issue here as the static/essential types are not one
  // of the essential type categories.
  struct S1 {
    int m1;
  };
  _Generic((const struct S1){.m1 = 0}, default : 1);
}