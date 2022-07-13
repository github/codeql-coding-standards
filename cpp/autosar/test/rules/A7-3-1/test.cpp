struct S1 {
  int i;
};

class C1 {
public:
  void f1(int);

  virtual void f2(int);
  virtual void f2(double);
  virtual void f2(S1);
};

class C2 : public C1 {
public:
  void f1(double); // NON_COMPLIANT

  void f2(double) override; // NON_COMPLIANT
};

class C3 : public C1 {
public:
  void f2(char *); // NON_COMPLIANT
};

class C4 : public C1 {
public:
  using C1::f1;
  void f1(double); // COMPLIANT

  using C1::f2;
  void f2(double) override; // COMPLIANT
};

namespace ns1 {
void f1(int);
}

using ns1::f1;

namespace ns1 {
void f1(double); // NON_COMPLIANT
}

void f1() {
  C2 l1;
  l1.f1(0); // calls C2::f1(double) instead of C1::f1(int)
  l1.f2(0); // calls C2::f2(double) instead of C1::f2(int)
  // S1 s1;
  // l1.f2(s1); Won't compile because there is no suitable conversion fro S1 to
  // double.
  C1 &l2{l1};
  l2.f1(0); // calls C1::f1(int)

  C4 l3;
  l3.f1(0);   // calls C1::f1(int)
  l3.f1(0.0); // calls C3::f1(double)
  l3.f2(0);   // calls C1::f2(int)
  l3.f2(0.0); // calls C3::f2(double)
  S1 l4;
  l3.f2(l4); // calls C1:f2(S1)
}
