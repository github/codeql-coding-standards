#include <iostream>
#include <string>
#include <utility>

class C1 {
public:
  C1() : m1(0), m2("") {}
  C1 &operator=(C1 const &p1) {
    m1 = p1.m1; // COMPLIANT
    // m2 = p1.m2; // COMPLIANT, but not supported by C++ 14
    return *this;
  }

private:
  int m1;
  std::string m2;
};

class C2 {
public:
  C2() : m1(nullptr) {}
  C2 &operator=(C2 &&p1) {
    m1 = std::move(p1.m1);
    p1.m1 = nullptr; // COMPLIANT - leaving the moved from object in a valid
                     // state, because destructor ~C2 will release resources.
    return *this;
  }
  ~C2() { delete m1; }

private:
  int *m1;
};

class C3 {
public:
  C3() : m1(0) {}
  C3 &operator=(C3 const &p1) {
    m1 = p1.m1; // COMPLIANT
    m1 += 1;    // NON_COMPLIANT - unrelated side effect
    int l1 = 0;
    l1 = l1++ + 1; // COMPLIANT - local side effect
    return *this;
  }

private:
  int m1;
};

class C4 {
public:
  C4() : m1(0) {}
  C4 &operator=(C4 const &p1) {
    std::cout << "Copying class C4"
              << std::endl; // NON_COMPLIANT - peformance overhead affecting the
                            // copying of th object?
    return *this;
  }

private:
  int m1;
};

struct S1 {
  int m1;
  S1 &operator=(S1 const &p1) {
    m1 = p1.m1 + 1; // NON_COMPLIANT
    return *this;
  }
};

class C5 {
public:
  C5() : m1(0), m2({0}) {}
  C5 &operator=(C5 const &p1) {
    m1 = p1.m1 + 1; // NON_COMPLIANT
    m2 = p1.m2; // NON_COMPLIANT - overloaded operator= has an unrelated side
                // effect, alert will be trigger in the definition
    m3 = 0;     // NON_COMPLIANT - unrelated side effect, should copy value from
                // p1.m3
    return *this;
  }

private:
  int m1;
  S1 m2;
  int m3;
};

class C6 {
public:
  C6() : m1(nullptr) {}
  C6 &operator=(C6 &&p1) {
    m1 = std::move(p1.m1); // COMPLIANT
    m2 = p1.m2;            // COMPLIANT
    m3 = 2;                // NON_COMPLIANT
    *m1 += 1;              // NON_COMPLIANT
    p1.m2 = -1; // COMPLIANT - leaving the moved from object in a valid state,
    return *this;
  }
  ~C6() { delete m1; }

private:
  int *m1;
  int m2;
  int m3;
};

class C7 {
public:
  C7() {}
  C7 &operator=(C7 &p1) {
    if (this != &p1) {
      for (int i = 0; i < 7; i++) {
        m1[i] = p1.m1[i]; // COMPLIANT
      }
    }
  }

private:
  int m1[7];
};

struct Baz {
  int quux;
};

struct Bar {
  struct Baz baz;
};

struct Foo {
  struct Bar bar;
};

class C8 {
public:
  C8() {}
  C8 &operator=(C8 &p1) {
    m1 = p1.m1;
    setM2(p1.m2);                  // COMPLIANT
    setQuux1(p1.foo.bar.baz.quux); // COMPLIANT
    setQuux2(p1.foo.bar.baz);      // COMPLIANT
    setQuux3(&p1.foo.bar.baz);     // COMPLIANT
    setQuux4(p1.foo.bar);          // COMPLIANT
    setQuux5(&p1.foo.bar);         // COMPLIANT
    setQuux6(p1.foo);              // COMPLIANT
    setQuux7(&p1.foo);             // COMPLIANT
    setQuux8(p1);                  // COMPLIANT
    setQuux9(&p1);                 // COMPLIANT
    setQuux10(p1);                 // COMPLIANT
  }

  void setM2(int p1) { m2 = p1; }

  void setQuux1(int p1) { foo.bar.baz.quux = p1; }

  void setQuux2(Baz const &p1) { foo.bar.baz.quux = p1.quux; }

  void setQuux3(Baz *p1) { foo.bar.baz.quux = p1->quux; }

  void setQuux4(Bar const &p1) { foo.bar.baz.quux = p1.baz.quux; }

  void setQuux5(Bar const *p1) { foo.bar.baz.quux = p1->baz.quux; }

  void setQuux6(Foo const &p1) { foo.bar.baz.quux = p1.bar.baz.quux; }

  void setQuux7(Foo const *p1) { foo.bar.baz.quux = p1->bar.baz.quux; }

  void setQuux8(C8 &p1) { foo.bar.baz.quux = p1.foo.bar.baz.quux; }

  void setQuux9(C8 *p1) { foo.bar.baz.quux = p1->foo.bar.baz.quux; }

  void setQuux10(C8 &p1) {
    setQuux1(p1.foo.bar.baz.quux);
    setQuux2(p1.foo.bar.baz);
    setQuux4(p1.foo.bar);
    setQuux6(p1.foo);
    setQuux8(p1);
  }

private:
  int m1;
  int m2;
  struct Foo foo;
};

class C9 {
public:
  C9() {}
  C9 &operator=(C9 &&p1) {
    if (this != &p1) {
      for (int i = 0; i < 7; i++) {
        m1[i] = p1.m1[i]; // COMPLIANT
      }
    }
  }

private:
  int m1[7];
};

class C10 {
public:
  C10() {}
  C10 &operator=(C10 &&p1) {
    m1 = p1.m1;
    setM2(p1.m2); // COMPLIANT
  }

  void setM2(int p1) { m2 = p1; }

private:
  int m1;
  int m2;
};