int g[1] = {1};
auto volatile [g1] = g; // NON_COMPLIANT
volatile int g2;        // COMPLIANT

void f(volatile int p) { // NON_COMPLIANT
  volatile int x = 1;    // NON_COMPLIANT
  int y = 2;             // COMPLIANT

  int z[1] = {1};
  auto volatile [a] = z; // NON_COMPLIANT
}

volatile int f1(); // NON_COMPLIANT

void f2(volatile int *p); // COMPLIANT
void f3(int *volatile p); // NON_COMPLIANT

class C {
public:
  volatile int m(); // NON_COMPLIANT
  int m1();         // COMPLIANT
  volatile int m2;  // COMPLIANT
};

struct S {
  volatile int s; // COMPLIANT
};