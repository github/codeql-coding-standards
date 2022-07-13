struct A { // COMPLIANT
  int a;
};

struct B { // NON_COMPLIANT
  int a;

private:
  int b; // NON_COMPLIANT
};

struct C { // NON_COMPLIANT
  int a;
  void f1() {}
};

struct D { // NON_COMPLIANT
public:
  int a;
  void f1() {}
};

struct E { // NON_COMPLIANT
private:
  int a; // NON_COMPLIANT
  void f1() {}
};

struct F { // NON_COMPLIANT - used in the derivation of H
  int a;

  class C1 {};
};

class C2 { // ignored, as the rule doesn't apply to classes
public:
  int a;
  void f() {}
};

struct G : C2 { // NON_COMPLIANT - derives from C2
  int c;
};

struct H : F { // NON_COMPLIANT
  int c;
};

struct I : G { // NON_COMPLIANT - derives from G
  int c;
};