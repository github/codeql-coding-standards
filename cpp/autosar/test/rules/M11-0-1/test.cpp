
class A {
public:
  virtual void a() {}
};

class A1 : A {
public:
  int a; // NON-COMPLIANT
};

class B {
public:
  virtual void b() {}
};

class B2 : B {
private:
  int b; // COMPLIANT
};

class B3 : B {
protected:
  int b; // NON-COMPLIANT
};

struct S1 {
  int s1; // COMPLIANT
};