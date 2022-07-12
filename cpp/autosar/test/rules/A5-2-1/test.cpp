struct Base {
  virtual ~Base() {}
};

struct Derived : Base {
  virtual void name() {}
};

void test_dynamic_cast() {
  Base *b1 = new Base;
  // NON_COMPLIANT
  if (Derived *d = dynamic_cast<Derived *>(b1)) {
    d->name();
  }

  Base *b2 = new Derived;
  // COMPLIANT
  if (Derived *d = dynamic_cast<Derived *>(b2)) {
    d->name();
  }

  delete b1;
  delete b2;
}