class A {
protected:
  virtual void virt1() {}
  virtual void virt2() {}
  virtual void virt3() {}

public:
  A() {
    virt1(); // NON_COMPLIANT
  }

  virtual ~A() {
    virt2_wrapper(); // NON_COMPLIANT
    virt2();         // NON_COMPLIANT
  }

  void virt2_wrapper() { this->virt2(); }
};

class B : public A {
public:
  virtual ~B() = default;
  B() : A() {
    virt3();    // NON_COMPLIANT
    A::virt2(); // COMPLIANT
  }

protected:
  void virt1() override {
    A::virt1(); // COMPLIANT
  }

  void virt2() override {
    A::virt2(); // COMPLIANT
  }

  void virt3() override {
    A::virt2(); // COMPLIANT
  }
};

class C : public B {
public:
  void virt3() override { return; }
};