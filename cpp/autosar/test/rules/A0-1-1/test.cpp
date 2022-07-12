
// A POD class
struct A {
  int f;
  int f2;
};
// A non-POD class, with a trivial compiler generated constructor
struct B {
  int f;
  void g();
  ~B();
};
// A non-POD class
struct C {
  C() : m(){};
  ~C();
  int m;
};

int test_useless_assignment(int &x, int p) {
  x = 0; // COMPLIANT - x is a reference parameter, so is visible by the caller
  int y = 0; // NON_COMPLIANT - never used
  y = 4;     // COMPLIANT - used outside the local scope
  int z = 0; // COMPLIANT - used later in the function
  z++;       // NON_COMPLIANT - never used

  int l1 = 0; // COMPLIANT - l1 is a loop control variable, and is later read
  for (; l1 != 3;) {
    l1++; // COMPLIANT - l1 is a loop control variable, and is later read
  }
  l1 = 4; // COMPLIANT - l1 is a loop control variable

  int l2 = 0; // COMPLIANT - read after if statement if p == 0
  if (p == 0) {
    l2 = 1; // COMPLIANT - read after if statement
  } else {
  }
  l2 + 5;

  p = 0; // COMPLIANT - parameter later read
  p + 5;
  p = 5; // NON_COMPLIANT - parameter value never read

  int l3{0U};           // NON_COMPLIANT
  int *l4 = new int(3); // NON_COMPLIANT - unused assignment

  A a1;            // COMPLIANT - no assignment, just unused
  A a2{};          // NON_COMPLIANT - POD class, no constructor/destructor
  A *a3 = new A;   // NON_COMPLIANT - POD class, no constructor/destructor
  A *a4 = new A(); // NON_COMPLIANT - POD class, no constructor/destructor
  A *a5 = nullptr; // NON_COMPLIANT - null never read
  A a6{};          // COMPLIANT - `m` assigned below
  a6.f = 2; // COMPLIANT - we don't track the fields here, but we do track `a6`,
            // so we'd consider this used by the assignment below
  a6.f = 1; // NON_COMPLIANT - assignment into `f`, but `a6` is not used
            // throughout the rest of the function

  B b1;          // COMPLIANT - calls the destructor at the end of the function
  B b2{};        // COMPLIANT - calls the destructor at the end of the function
  B *b3 = new B; // NON_COMPLIANT - no constructor call
  B *b4 = new B(); // NON_COMPLIANT - no constructor call
  B *b5 = nullptr; // NON_COMPLIANT - null never read
  B *b6 = new B(); // COMPLIANT - function called below
  b6->g();

  C c1;            // COMPLIANT - calls a constructor/destructor
  C c2{};          // COMPLIANT - calls a constructor/destructor
  C *c3 = new C;   // COMPLIANT - this will call a constructor??
  C *c4 = new C(); // COMPLIANT - this will call a constructor??
  C *c5 = nullptr; // NON_COMPLIANT - null never read

  return y;
}
