struct S1 {
  virtual void f1() {}
  int m1;
};

struct S2 : S1 {
  virtual void f2() {}
  int m2;
};

struct S3 : S1 {
  int m1;
  int m2; // same member as S2, but different object representation
};

S1 *return_ptr_to_created_s1() { return new S1; }
S1 &return_ref_to_static_s1() {
  static S1 s1;
  return s1;
}
void return_ptr_in_arg_to_created_s1(S1 **ptr) { *ptr = new S1; }
S1 *return_ptr_to_created_s2() { return new S2; }
void return_ptr_in_arg_to_created_s2(S1 **ptr) { *ptr = new S2; }

void f0() {
  S1 *l1 = new S1;
  S1 l2;

  void (S1::*l3)() = static_cast<void (S1::*)()>(&S2::f1);
  void (S1::*l4)() = static_cast<void (S1::*)()>(&S2::f2);

  (l1->*l3)(); // COMPLIANT
  (l2.*l3)();  // COMPLIANT
  (l1->*l4)(); // NON_COMPLIANT
  (l2.*l4)();  // NON_COMPLIANT

  int S1::*l5 = (int(S1::*)) & S2::m1;
  int S1::*l6 = (int(S1::*)) & S2::m2;

  l1->*l5; // COMPLIANT
  l1->*l6; // NON_COMPLIANT

  S2 l7;
  int S1::*l8 = static_cast<int S1::*>(&S3::m2);
  l7.*l8; // NON_COMPLIANT; different object representations between S2 and S3.

  S1 *l9 = return_ptr_to_created_s1();
  l9->*l5; // COMPLIANT
  l9->*l6; // NON_COMPLIANT
  delete l9;

  S1 *l10 = nullptr;
  return_ptr_in_arg_to_created_s1(&l10);
  l10->*l5; // COMPLIANT
  l10->*l6; // NON_COMPLIANT
  delete l10;

  S1 *l11 = return_ptr_to_created_s2();
  l11->*l5; // COMPLIANT
  l11->*l6; // COMPLIANT
  delete l11;

  S1 *l12 = nullptr;
  return_ptr_in_arg_to_created_s2(&l12);
  l12->*l5; // COMPLIANT
  l12->*l6; // COMPLIANT
  delete l12;

  delete l1;
}

void f2(S1 *p1) {
  void (S1::*l1)() = static_cast<void (S1::*)()>(&S2::f1);
  void (S1::*l2)() = static_cast<void (S1::*)()>(&S2::f2);

  (p1->*l1)(); // COMPLIANT
  (p1->*l2)(); // NON_COMPLIANT
}

void f3(S1 *p1) {
  void (S1::*l1)() = static_cast<void (S1::*)()>(&S2::f1);
  void (S1::*l2)() = static_cast<void (S1::*)()>(&S2::f2);

  (p1->*l1)(); // COMPLIANT
  (p1->*l2)(); // COMPLIANT
}

void f4() {
  S1 *l1 = new S1;
  S1 *l2 = new S2;

  f2(l1);
  f3(l2);
}
