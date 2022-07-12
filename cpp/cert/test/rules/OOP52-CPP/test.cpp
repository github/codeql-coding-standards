class Base {
  virtual void foo() {}
};

class BaseWithVirtualDestructor {
public:
  virtual void bar() {}
  virtual ~BaseWithVirtualDestructor() = default;
};

class DerivedA : public Base {
  void foo() {
    delete this; // NON_COMPLIANT
  }
};

class DerivedB final : public DerivedA {
  void foo() {
    delete this; // COMPLIANT
  }
};

class DerivedC : public BaseWithVirtualDestructor {
  void bar() {
    delete this; // COMPLIANT
  }
};

void test() {
  DerivedA *a1 = new DerivedA();   // COMPLIANT
  DerivedB *b1 = new DerivedB();   // COMPLIANT
  a1 = (DerivedA *)b1;             // NON_COMPLIANT
  DerivedA *a2 = nullptr;          // COMPLIANT
  DerivedC *c1 = new DerivedC();   // COMPLIANT
  a2 = (DerivedA *)new DerivedB(); // NON_COMPLIANT
  Base *d1 = new Base();           // COMPLIANT

  /*   std::unique_ptr<Base> ptr1 = std::make_unique<Base>(); // COMPLIANT

    std::unique_ptr<DerivedA> ptr3 = std::make_unique<DerivedA>(); // COMPLIANT

    std::unique_ptr<DerivedB> ptr4 = std::make_unique<DerivedB>(); // COMPLIANT

    std::unique_ptr<DerivedC> ptr5 = std::make_unique<DerivedC>(); // COMPLIANT

    std::unique_ptr<BaseWithVirtualDestructor> ptr6 =
        std::make_unique<DerivedC>(); // COMPLIANT

    std::unique_ptr<DerivedA> ptr7(a1); // COMPLIANT

    std::unique_ptr<DerivedA> ptr8(b1); // NON_COMPLIANT */
}