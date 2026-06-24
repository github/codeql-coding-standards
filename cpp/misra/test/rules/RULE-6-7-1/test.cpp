int f();

int g = 0; // COMPLIANT

void f1() {
  int i = 0;                   // COMPLIANT
  static int i1 = 0;           // NON_COMPLIANT
  static constexpr int i2 = 0; // COMPLIANT
  static const int i3 = f();   // COMPLIANT
}

class A {
  static A theClass() {
    static A a; // NON_COMPLIANT
    return a;
  }
};