class A {
public:
  int v1;
  int v2;
  void f1();

private:
  int v3;
  void f2();
  void f3();
};

class B {
public:
  int v1;
  int v3;
  void f2();

private:
  int v4;
  void f3();
};

class C : private A { // COMPLIANT
public:
  int v2;
  void f3();
};

class D : public A, protected B { // NON_COMPLIANT
  int v3;
  int v4;
  void f1();
  void f2();
  void f3();
};

class E : protected B, protected C { // COMPLIANT
public:
  void f2();
};