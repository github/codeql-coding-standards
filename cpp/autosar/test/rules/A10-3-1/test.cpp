class Base {
public:
  virtual ~Base(){};    // COMPLIANT
  virtual void F() = 0; // COMPLIANT
  virtual void
  G() final = 0;        // NON_COMPLIANT : declared both "virtual" and "final"
  virtual void H() = 0; // COMPLIANT
  virtual void Z() = 0;
};

class Derived : public Base {
public:
  ~Derived() override{};       // COMPLIANT
  virtual void F() override{}; // NON_COMPLIANT : "virtual" and "override"
  void H() override{};         // COMPLIANT
  void Z() final{};            // COMPLIANT
};