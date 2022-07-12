struct A {

  virtual ~A() = default;
  void F1() noexcept {}
  void F2() noexcept {}
  virtual void F3() noexcept {}
};

void Fn() {
  bool b1 = (&A::F1 == &A::F2);  // COMPLIANT
  bool b2 = (&A::F1 == nullptr); // COMPLIANT
  bool b3 = (&A::F3 == nullptr); // COMPLIANT
  bool b4 = (&A::F3 != nullptr); // COMPLIANT
  bool b5 = (&A::F3 == &A::F1);  // NON_COMPLIANT
  bool b6 = (&A::F3 == &A::F2);  // NON_COMPLIANT
  bool b7 = (&A::F2 == nullptr); // COMPLIANT
}