class A {
public:
  int getA1() { return a; }

  int &getA2() { return a; }

  int *getA3() {
    int *aa = &a;
    return aa;
  }

  int *getA33() { return &a; }

  const int &getA4() { return a; }

  const int *getA5() { return &a; }

  int getB1() { return b; }

  int &getB2() { return b; } // NON_COMPLIANT

  int *getB3() { return &b; } // NON_COMPLIANT

  int *getB33() { // NON_COMPLIANT
    int *bb = &b;
    return bb;
  }

  const int &getB4() { return b; }

  const int *getB5() { return &b; }

  int getC1() { return c; }

  int &getC2() { return c; } // NON_COMPLIANT

  int *getC3() { return &c; } // NON_COMPLIANT
  int *getC33() {             // NON_COMPLIANT
    int *cc = &c;
    return cc;
  }

  const int &getC4() { return c; }

  const int *getC5() { return &c; }
  const int *getC55() {
    int *cc = &c;
    return cc;
  }

  int a;

private:
  int b;

protected:
  int c;
};