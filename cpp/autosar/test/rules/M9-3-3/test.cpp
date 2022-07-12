class B {
public:
  int b;
};

class D {
public:
  static int d;
};

class C : public D {};

class A : public C {
private:
  int m;
  static int m1;

public:
  int f() { // NON_COMPLIANT
    // can be static - only accesses own members that are statics
    // can also be const for same reason
    B b = B();
    b.b = 1;
    m1 = f3();
    d = 7;
    return m1;
  }
  int f1() { // COMPLIANT
    // cannot be static -accesses non static m
    return m++;
  }
  int f2() { // COMPLIANT
    // cannot be static -accesses non static m
    return m;
  }

  static int f3() {
    // already static
    // cannot be const, is static
    return m1;
  }

  void f4() { // COMPLIANT
    // cannot be static - calls non static f2
    int l = f2();
  }
};

class E {
public:
  int m;
};

class F {
  friend E &operator+(E &e, F *f);
  E f1(E &e) { // COMPLIANT
    // cannot be static - accesses this
    // can be const though
    return e + this;
  }

private:
  int m;
};

class G {
public:
  int g;
};

class H : public G {};

class I : public H {
private:
  int m;

public:
  int f() { // NON_COMPLIANT
    // can be const - only modifies other members
    B b = B();
    b.b = 1;
    int l = f3();
    l = g;
    return m;
  }
  int f1() { // NON_COMPLIANT
    // can be const - does not modify any member
    int i = 1;
    i = i + 1;
    return m;
  }
  int f2() { // COMPLIANT
    // cannot be const - modifies a member
    return g++;
  }

  int f3() const {
    // already const
    return m;
  }

  void f4() { // COMPLIANT
    // cannot be const - calls f5 which calls f2 which modifies a member
    int l = f5();
  }

  int f5() { // COMPLIANT
    // cannot be const - calls f2 which modifies a member
    return f2();
  }

  void f6() { // COMPLIANT
    // cannot be const - modifies this
    I *i = new I();
    *this = *i;
  }
};

class Y {
public:
  int y;
  void setY() { // COMPLIANT
    y += 1;
  }
};

class X {
public:
  Y y;
  void callSet() { // COMPLIANT
    y.setY();
  }
};

class Z {
public:
  int a;
  virtual void f1() = 0;               // COMPLIANT
  void f2() {}                         // NON_COMPLIANT
  virtual void f3() {}                 // NON_COMPLIANT
  virtual void f4() const noexcept {}  // COMPLIANT
  virtual void f5() { this->a = 100; } // COMPLIANT
};

class Z1 {
public:
  int a = 0;
  virtual void f() = 0;          // COMPLIANT
  virtual void f2() { a = 100; } // COMPLIANT
  virtual void f3() {}           // NON_COMPLIANT
};

class Z2 : Z1 {
  void f() override {}                  // COMPLIANT
  void f2() override { this->a = 100; } // COMPLIANT
  void f3() override {}                 // COMPLIANT
};

class Z22 : Z1 {
  void f() override { this->a = 100; } // COMPLIANT
  void f2() final {}                   // COMPLIANT
  void f3() { this->a = 100; }         // COMPLIANT
};
