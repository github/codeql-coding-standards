class A {
private:
  int *a;
  int &b;

public:
  A(int &bparam) : b(bparam) { a = new int[1]; }
  int *getA() const { return a; }             // NON_COMPLIANT
  int *getB() const { return &b; }            // NON_COMPLIANT
  const int *getBConst() const { return &b; } // COMPLIANT
  A *getThis() const { return (A *)this; }    // NON_COMPLIANT
};