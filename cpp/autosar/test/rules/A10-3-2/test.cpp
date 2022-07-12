class Base {
public:
  virtual ~Base(){};
  virtual void F() = 0;
  virtual void G(){};
  virtual void H(){};
};

class Derived : public Base {
  ~Derived() override{}; // COMPLIANT

  void F(){};          // NON_COMPLIANT
  void G() override{}; // COMPLIANT
  void H() final{};    // COMPLIANT
};

class Base466 {
public:
  virtual ~Base466() = default;
};

class Derived466 final : public Base466 {
  // ~Derived466() // COMPLIANT
};