
class Base {
public:
  virtual ~Base() = default;
  virtual void f() = 0;
  virtual void g(){};
};

class Derived final : public Base {
public:
  void f() final{};    // COMPLIANT
  void g() override{}; // NON_COMPLIANT

  virtual void h() = 0; // NON_COMPLIANT
};