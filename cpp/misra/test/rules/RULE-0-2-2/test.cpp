void f0(int x) {}     // NON_COMPLIANT
void f1(int x) { x; } // COMPLIANT
void f2(int) {}       // COMPLIANT

void f3(int);
void f3(int) {} // COMPLIANT

void f4(int);
void f4(int x) {} // NON_COMPLIANT

void f5(int);
void f5(int x) { x; } // COMPLIANT

void f6(int x);
void f6(int) {} // COMPLIANT

void f7(int x);
void f7(int y) {} // NON_COMPLIANT

void f8(int i);
void f8(int y) {} // NON_COMPLIANT

class C1 {
  virtual void m0(int x) {}                  // NON_COMPLIANT
  virtual void m1(int) {}                    // COMPLIANT
  virtual void m2([[maybe_unused]] int x) {} // COMPLIANT
};

class C2 : C1 {
  void m0(int) override {} // COMPLIANT
  void m1(int) override {} // COMPLIANT
  void m2(int) override {} // COMPLIANT
};

class C3 : C1 {
  void m0(int x) override {} // NON_COMPLIANT
  void m1(int x) override {} // NON_COMPLIANT
  void m2(int x) override {} // NON_COMPLIANT
};

class C4 : C1 {
  void m0([[maybe_unused]] int x) override {} // COMPLIANT
  void m1([[maybe_unused]] int x) override {} // COMPLIANT
  void m2([[maybe_unused]] int x) override {} // COMPLIANT
};